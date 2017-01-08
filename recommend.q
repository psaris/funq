\c 22 100
\l funq.q

f:("ml-latest";"ml-latest-small") 1 / pick the smaller dataset
b:"http://files.grouplens.org/datasets/movielens/" / base url
-1"[down]loading latest grouplens movie lense (small) dataset";
.util.download[b;;".zip";system 0N!"unzip ",] f;         / download data
/ integer movieIds, enumerate genres, link movieId, and store ratings as real to save space
-1"loading movie definitions: integer movieIds and enumerated genres";
movie:("I**";1#",") 0:`$f,"/movies.csv"
movie:update rtrim title from movie
-1"extract the movie's year from title";
movie:update year:"I"$-1_/:-5#/:title,-7_/:title from movie where title like "*(????)"
-1"remove movies without genres";
movie:update 0#'genres from movie where genres like "(no genres listed)"
-1"use the movie's year as a genre";
movie:1!update `u#movieId,`genre?/:`$(enlist'[string 10 xbar year],'"|"vs'genres) from movie
-1"loading movie ratings: partitioned by userId and movieId linked to movie table";
rating:update `p#userId,`movie$movieId from ("IIF";1#",") 0:`$f,"/ratings.csv"

-1"to ensure the ratings matrix only contains movies with ratings,";
-1"we generate a list of all the unique movie ids listed in the ratings table";
show um:exec distinct asc movieId from rating / unique movies

-1"we now build a dataset to hold our own ratings/preferences";
r:([movieId:um]rating:count[um]#0n) / initial ratings
r,:([]movieId:260 1197 2005 1968 2918i;rating:4 4 4 4 5f)
r,:([]movieId:4006 53996 69526 87520 112370 86898i;rating:5 4 4 5 5 .5)
show select from r lj movie where not null rating  / my ratings

rpt:lj[;movie] `score xdesc     / projecting to sort ratings and append movie title
/ http://files.grouplens.org/papers/FnT%20CF%20Recsys%20Survey.pdf

/ content based filtering

-1"content based filtering does not use ratings from other people";
-1"it uses our own preferences mixed with each movie's genre";
Y:enlist value[r]`rating
-1"we build the X matrix based on each movie's genres";
show X:flip exec genre in/: genres from ([]movieId:um)#movie
-1"we then randomly initialize the theta matrix";
theta:raze -1+(1+count X)?/:count[Y]#2f
-1"since we don't use other user's preferences, this is quick optimization";
theta:first .fmincg.fmincg[0W;.ml.rcbfcostgrad[0f;X;Y];theta] / learn
THETA:(count[Y];0N)#theta
-1"view our deduced genre preferences";
show desc genre!1_last THETA
-1"how closely do the computed scores match our preferences";
show rpt select from (update score:last .ml.predict[X;THETA] from r) where not null rating
-1"and finally, show the recommendations";
show rpt update score:last .ml.predict[X;THETA] from r

/ collaborative filter

/ http://webdam.inria.fr/Jorge/html/wdmch19.html
-1"we begin be reporting summary statistics about the ratings dataset";
-1"support";
-1"reporting the number of users, movies and ratings";
show exec nu:count distinct userId, nm:count distinct movieId, nr:count i from rating
-1"distribution:";
-1"we can see that only users with >20 ratings are included";
show select nu:count userId by nr from select nr:10 xbar count rating by userId from rating
-1"we can also see that a large majority of movies have less than 10 ratings";
show select nm:count movieId by nr from select nr:10 xbar count rating by movieId from rating
-1"quality:";
-1"we can see that there is a positive bias to the ratings";
show exec `min`med`avg`mode`max!(min;med;avg;.ml.mode;max)@\:rating from rating
/rating:select from rating where 19<(count;i) fby userId,9<(count;i) fby movieId
-1"the average rating per user is distributed around 3.5";
show select nu:count i by rating from select .5 xbar avg rating by userId from rating
-1"and the average rating per movie is similarly distributed";
show select nm:count i by rating from select .5 xbar avg rating by movieId from rating
-1"movies with a small number of ratings can distort the rankings";
-1"the top rankings are dominated by movies with a single rating";
show select[10;>rating] avg rating, n:count i by movieId.title from rating
-1"while the most rated movies have averages centered around 4";
show select[10;>n] avg rating, n:count i by movieId.title from rating
-1"we will therefore demean the ratings before performing our analysis";
-1"";
-1"by using a syntax that is similar to pivoting,";
-1"we can generate the user/movie matrix";

show R:value exec (movieId!rating) um by userId from rating

-1"user-user collaborative filtering fills missing ratings";
-1"with averaged values from users who's ratings are most similar to ours";
-1"we have many choices to make:";
-1"[ ] should we demean and/or z-score the data to remove bias?";
-1"[ ] should we use Pearson's correlation (cor) or Spearman's (.ml.scor)";
-1"[ ] should we use cosine similarity instead?";
-1"[ ] once we find the top n most similar users, should we:";
-1"z-score and equally average top n users based on correlation";
show rpt update score:.ml.fzscore[.ml.uucf[cor;.ml.navg[20];0f^.ml.zscore R]0f^] rating from r
-1"zscore and weighted average top n users based on correlation";
show rpt update score:.ml.fzscore[.ml.uucf[cor;.ml.nwavg[20];0f^.ml.zscore R]0f^] rating from r
-1"demean and weighted average top n users based on spearman correlation";
show rpt update score:.ml.fdemean[.ml.uucf[.ml.scor;.ml.nwavg[20];0f^.ml.demean R]0f^] rating from r
-1"demean and weighted average top n users based on cosine similarity";
show rpt update score:.ml.fdemean[.ml.uucf[.ml.cossim;.ml.nwavg[20];0f^.ml.demean R]0f^] rating from r
-1"what if we would like recommend more niche movies.";
-1"ie: underweight movies with more ratings?";
-1"we can use the 'idf' (inverse document frequency) calculation ";
-1"from nlp (natural language processing)";
-1"demean and weighted average top n users based on cosine similarity of idf-adjusted ratings";
/ weight by inverse user frequencies to underweight universally liked movies
show rpt update score:.ml.fdemean[.ml.uucf['[.ml.cossim . .ml.idf[R]*/:;enlist];.ml.nwavg[20];0f^.ml.demean R]0f^] rating from r
-1 .util.box["**"] (
 "singular value decomposition (svd) allows us to compute latent factors (off-line)";
 "and perform simple matrix multiplication to make predictions (on-line)");
-1"demean and compute score based on top n svd factors";
usv:.qml.msvd 0f^R-\:a:.ml.frow[avg] R
show rpt update score:.ml.fdemean[first {x$z$/:y} . .ml.foldin[.ml.nsvd[30] usv;0b]0f^] rating from r
-1"we can even use svd to foldin a new movie";
.ml.foldin[.ml.nsvd[30] usv ;1b;1f^R[;2]]

-1 .util.box["**"] (
 "regularized gradient descent collaborative filtering";
 "doesn't need to be filled with default values";
 "and can use regularization");
R,:value[r]`rating
nu:count R;nm:count R 0;nf:20    / n users, n movies, n features
n:(nu;nf)
thetax:2 raze/ THETAX:(THETA:-1+nu?/:nf#2f;X:-1+nm?/:nf#2f)

-1"store average rating";
Y:R-\:a:.ml.frow[avg] R               / normalization data

-1"learn latent factors that best predict existing ratings matrix";
thetax:first .fmincg.fmincg[50;.ml.rcfcostgrad[1f;Y;n];thetax] / learn
-1"use 'where' to find list of coordinates of non-null items";
i:.ml.mwhere not null R
l:.06                         / lambda (l2 regularization coefficient)
-1"define cost function";
cf:.ml.rcfcost[l;Y] .
-1"define minimization function";
mf:.ml.rcfupd1[l;Y;.05]
-1"keep running mf until improvement is lower than pct limit";
c:();THETAX: .ml.until[`c;cf;.05] {x mf/ 0N?flip i}/ THETAX

-1"predict missing ratings";
P:a+/:.ml.mtm . THETAX:.ml.cfcut[n] thetax / predictions
show rpt update score:last P from r
-1"compare against existing ratings";
show rpt select from (update score:last P from r) where not null rating

/ Large-scale Parallel Collaborative Filtering for the Netflix Prize
/ http://dl.acm.org/citation.cfm?id=1424269

-1"Alterating Least Squares is used to factor the rating matrix";
-1"into a movie matrix (X) and user matrix (THETA)";
-1"by alternating between keeping X constant and solving for THETA";
-1"and vice versa.  this changes a non-convex problem";
-1"into a quadratic problem solvable with parallel least squares.";
-1"this implementation uses a weighting scheme where";
-1"the weights are equal to the number of ratings per user/movie";

l:.06;nf:20
-1"reset THETA and X";
THETAX:(THETA:-1+nu?/:nf#1f;X:-1+nm?/:nf#2f)
-1"set minimization function to alternating least squares";
mf:.ml.wrals[l;Y]
-1"keep running mf until improvement is lower than pct limit";
c:();THETAX:.ml.until[`c;cf;.001] mf/ THETAX

-1"predict missing ratings";
P:a+/:.ml.mtm . THETAX          / predictions
show rpt update score:last P from r
-1"limit recommendations to movies with many ratings";
ids:exec distinct movieId from rating where 200<(count;i) fby movieId
show rpt select from (update score:last P from r) where movieId in ids
-1"compare against existing ratings";
show rpt select from (update score:last P from r) where not null rating
