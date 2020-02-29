\c 22 100
\l funq.q
\l mlense.q

-1"reference mlense data from global namespace";
`rating`movie set' mlense`rating`movie

/ personal ratings

-1"we now build a dataset to hold our own ratings/preferences";
r:1!select `mlense.movie$movieId,rating:0n from movie
r,:([]movieId:173 208 260 435 1197 2005 1968i;rating:.5 .5 4 .5 4 4 4f)
r,:([]movieId:2918 4006 53996 69526 87520 112370i;rating:5 5 4 4 5 5f)
show select movieId,rating,movieId.title from r where not null rating

/ http://files.grouplens.org/papers/FnT%20CF%20Recsys%20Survey.pdf

/ content based filtering

-1"content based filtering does not use ratings from other people.";
-1"it uses our own preferences mixed with each movie's genre";
Y:value[r]1#`rating
-1"we build the X matrix based on each movie's genres";
show X:"f"$flip genre in/: value[movie]`genres
-1"we then initialize the THETA matrix";
theta:raze 0N!THETA:(1;1+count X)#0f
-1"since we don't use other user's preferences, this is quick optimization";
rf:.ml.l2[.1]                   / l2 regularization 
theta:first .fmincg.fmincg[20;.ml.lincostgrad[rf;Y;X];theta] / learn
-1"view our deduced genre preferences";
show {(5#x),-5#x}desc genre!1_theta
-1"how closely do the computed scores match our preferences";
THETA:(count[Y];0N)#theta
r:update score:first .ml.linpredict[X;THETA] from r
show select[>score] rating,score,movieId.title from r where not null rating
-1"and finally, show the recommendations";
show select[10;>score] movieId,score,movieId.title from r
-1"'Mars Needs Moms' was my top recommendation because it had so many genres";
select genres from movie where movieId = 85261

/ ratings data summary

/ http://webdam.inria.fr/Jorge/html/wdmch19.html
-1"we begin be reporting summary statistics about the ratings dataset";
-1"support";
-1"reporting the number of users, movies and ratings";
(count distinct@) each exec nu:userId, nm:movieId, nr:i from rating
-1"distribution:";
-1"we can see that only users with >20 ratings are included";
t:select nr:count rating by userId from rating
show select nu:count userId by 10 xbar nr from t
-1"we can also see that a large majority of movies have less than 10 ratings";
t:select nr:count rating by movieId from rating
show select nm:count movieId by 10 xbar nr from t
-1"quality:";
-1"we can see that there is a positive bias to the ratings";
show `min`med`avg`mode`max!(min;med;avg;.ml.mode;max)@\:rating`rating
/rating:select from rating where 19<(count;i) fby userId,9<(count;i) fby movieId
-1"the average rating per user (and movie) is distributed around 3.5";
t:select avg rating by movieId from rating
t:select nm:count i by .5 xbar rating from t
s:select avg rating by userId from rating
show t lj select nu:count i by .5 xbar rating from s
-1"movies with a small number of ratings can distort the rankings";
-1"the top rankings are dominated by movies with a single rating";
show select[10;>rating] avg rating, n:count i by movieId.title from rating
-1"while the most rated movies have averages centered around 4";
show select[10;>n] avg rating, n:count i by movieId.title from rating
-1"we will therefore demean the ratings before performing our analysis";
-1"";
-1"by using a syntax that is similar to pivoting,";
-1"we can generate the user/movie matrix";

/ https://grouplens.org/blog/similarity-functions-for-user-user-collaborative-filtering/

-1"to ensure the ratings matrix only contains movies with relevant movies,";
-1"we generate a list of unique movie ids that meet our threshold.";
n:20
show m:exec distinct movieId from rating where n<(count;i) fby movieId
show R:value exec (movieId!rating) m by userId from rating where movieId in m
-1"then add our own ratings";
R,:r[([]movieId:m);`rating]
-1"demean each user";
U:R-au:avg each R

k:30

/ user-user collaborative filtering

-1"user-user collaborative filtering fills missing ratings";
-1"with averaged values from users who's ratings are most similar to ours";

-1"average top ",string[k], " users based on correlation";
p:last[au]+.ml.fknn[1f-;.ml.cordist\:;k;U;0f^U] 0f^last U
show `score xdesc update score:p,movieId.title from ([]movieId:m)#r
-1"average top ",string[k], " users based on spearman correlation";
p:last[au]+.ml.fknn[1f-;.ml.scordist\:;k;U;0f^U] 0f^last U
show `score xdesc update score:p,movieId.title from ([]movieId:m)#r
-1"weighted average top ",string[k], " users based on cosine similarity";
-1"results in the same recommendations as .ml.cordist because the data";
-1"has been centered and filled with 0";
p:last[au]+.ml.fknn[1f-;.ml.cosdist\:;k;U;0f^U] 0f^last U
show `score xdesc update score:p,movieId.title from ([]movieId:m)#r

/ item-item collaborative filtering

-1"item-item collaborative filtering fills missing ratings";
-1"with averaged values from movies most similar to movies we've rated";

I-:ai:avg each I:flip R
-1"pre-build item-item distance matrix because item similarities are stable";
D:((0^I) .ml.cosdist\:) peach 0^I
-1"average top ",string[k], " items based on correlation";
p:ai+.ml.knn[1f-;k;last each I] D
show `score xdesc update score:p,movieId.title from ([]movieId:m)#r

nf:10;

if[2<count key `.qml;
 -1 .util.box["**"] (
  "singular value decomposition (svd) allows us to compute latent factors (off-line)";
  "and perform simple matrix multiplication to make predictions (on-line)");
 -1"compute score based on top n svd factors";
 
 / singular value decomposition

 usv:.qml.msvd 0f^U;
 -1"predict missing ratings using low rank approximations";
 P:a+{x$z$/:y} . .ml.nsvd[nf] usv;
 show t:`score xdesc update score:last P,movieId.title from ([]movieId:m)#r;
 -1"compare against existing ratings";
 show select from t where not null rating;
 -1"we can use svd to foldin a new user";
 .ml.foldin[.ml.nsvd[500] usv;0b] 0f^U[2];
 -1"or even a new movie";
 .ml.foldin[.ml.nsvd[500] usv;1b;0f^U[;2]];
 -1"what does the first factor look like?";
 show each {(5#x;-5#x)}([]movieId:m idesc usv[2][;0])#movie;
 -1"how much variance does each factor explain?";
 show .util.plot[40;19;.util.c10;avg] {x%sum x*:x}.qml.mdiag usv 1;
 ];

/ regularized gradient descent

-1 .util.box["**"] (
 "regularized gradient descent collaborative filtering";
 "doesn't need to be filled with default values";
 "and can use regularization");

n:(ni:count U 0;nu:count U) / (n items; n users)
-1"randomly initialize X and THETA";
xtheta:2 raze/ XTHETA:(X:-1+ni?/:nf#2f;THETA:-1+nu?/:nf#2f)

-1"learn latent factors that best predict existing ratings matrix";
xtheta:first .fmincg.fmincg[100;.ml.cfcostgrad[rf;n;U];xtheta] / learn

-1"predict missing ratings";
P:au+.ml.cfpredict . XTHETA:.ml.cfcut[n] xtheta / predictions
show t:`score xdesc update score:last P,movieId.title from ([]movieId:m)#r
-1"compare against existing ratings";
show select from t where not null rating

-1"check collaborative filtering gradient calculations";
.util.assert . .util.rnd[1e-6] .ml.checkcfgrad[1e-4;rf;20 5]

/ stochastic regularized gradient descent
-1"by solving for each rating, one at a time";
-1"we can perform stochastic gradient descent";
-1"randomly initialize X and THETA";
xtheta:2 raze/ XTHETA:(X:-1+ni?/:nf#2f;THETA:-1+nu?/:nf#2f)

-1"define cost function";
cf:.ml.cfcost[rf;U] .
-1"define minimization function";
mf:.ml.sgdmf[.05;.2;0N?;U;;::]
-1"keep running mf until improvement is lower than pct limit";
XTHETA:first .ml.iter[-1;.0001;cf;mf] XTHETA

-1"predict missing ratings";
P:au+.ml.cfpredict . XTHETA / predictions
show t:`score xdesc update score:last P,movieId.title from ([]movieId:m)#r
-1"compare against existing ratings";
show select from t where not null rating

/ weighted regularized alternating least squares

/ Large-scale Parallel Collaborative Filtering for the Netflix Prize
/ http://dl.acm.org/citation.cfm?id=1424269

-1"Alterating Least Squares is used to factor the rating matrix";
-1"into a user matrix (X) and movie matrix (THETA)";
-1"by alternating between keeping THETA constant and solving for X";
-1"and vice versa.  this changes a non-convex problem";
-1"into a quadratic problem solvable with parallel least squares.";
-1"this implementation uses a weighting scheme where";
-1"the weights are equal to the number of ratings per user/movie";

-1"reset X and THETA";
XTHETA:(X:-1+ni?/:nf#1f;THETA:-1+nu?/:nf#2f)
-1"keep running mf until improvement is lower than pct limit";

XTHETA:first .ml.iter[1;.0001;.ml.cfcost[();U] .;.ml.wrals[.01;U]] XTHETA

-1"predict missing ratings";
P:au+.ml.cfpredict . XTHETA / predictions
show t:`score xdesc update score:last P,movieId.title from ([]movieId:m)#r
-1"compare against existing ratings";
show s:select from t where not null rating
.util.assert[0f] .util.rnd[.01] avg exec .ml.mseloss[rating;score] from s
