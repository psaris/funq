\c 22 100
\l funq.q
\l mlense.q

/ personal ratings

-1"we now build a dataset to hold our own ratings/preferences";
r:1!select `mlense.movie$movieId,rating:0n from mlense.movie
r,:([]movieId:173 208 260 435 1197 2005 1968i;rating:.5 .5 4 .5 4 4 4f)
r,:([]movieId:2918 4006 53996 69526 87520 112370i;rating:5 5 4 4 5 5f)
show select movieId,rating,movieId.title from r where not null rating

/ http://files.grouplens.org/papers/FnT%20CF%20Recsys%20Survey.pdf

/ content based filtering

-1"content based filtering does not use ratings from other people.";
-1"it uses our own preferences mixed with each movie's genre";
Y:value[r]1#`rating
-1"we build the X matrix based on each movie's genres";
show X:"f"$flip genre in/: value[mlense.movie]`genres
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
select genres from mlense.movie where movieId = 85261

/ ratings data summary

/ http://webdam.inria.fr/Jorge/html/wdmch19.html
-1"we begin be reporting summary statistics about the ratings dataset";
-1"support";
-1"reporting the number of users, movies and ratings";
(count distinct@) each exec nu:userId, nm:movieId, nr:i from mlense.rating
-1"distribution:";
-1"we can see that only users with >20 ratings are included";
t:select nr:count rating by userId from mlense.rating
show select nu:count userId by 10 xbar nr from t
-1"we can also see that a large majority of movies have less than 10 ratings";
t:select nr:count rating by movieId from mlense.rating
show select nm:count movieId by 10 xbar nr from t
-1"quality:";
-1"we can see that there is a positive bias to the ratings";
show `min`med`avg`mode`max!(min;med;avg;.ml.mode;max)@\:mlense.rating`rating
/rating:select from rating where 19<(count;i) fby userId,9<(count;i) fby movieId
-1"the average rating per user (and movie) is distributed around 3.5";
t:select avg rating by movieId from mlense.rating
t:select nm:count i by .5 xbar rating from t
s:select avg rating by userId from mlense.rating
show t lj select nu:count i by .5 xbar rating from s
-1"movies with a small number of ratings can distort the rankings";
-1"the top rankings are dominated by movies with a single rating";
show select[10;>rating] avg rating, n:count i by movieId.title from mlense.rating
-1"while the most rated movies have averages centered around 4";
show select[10;>n] avg rating, n:count i by movieId.title from mlense.rating
-1"we will therefore demean the ratings before performing our analysis";
-1"";
-1"by using a syntax that is similar to pivoting,";
-1"we can generate the user/movie matrix";

-1"to ensure the ratings matrix only contains movies with relevant movies,";
-1"we generate a list of unique movie ids that meet our threshold.";
n:20
show m:exec distinct asc movieId from mlense.rating where n<(count;i) fby movieId
r:([]movieId:m)#r

show R:value exec (movieId!rating) m by userId from mlense.rating where ([]movieId) in key r
-1"then add our own ratings";
R,:value[r]`rating
-1"demean the data and store global/user bias";
b:avg 2 raze/ R                         / bias
Y:Y-ub:avg each Y:Y-\:mb:.ml.navg Y:R-b / bias, move bias, user bias
Y:Y-ub:avg each Y:R;b:0f;mb:0f          / user bias
/Y:Y-ub:avg each Y:R-b;mb:0f             / bias, user bias
/Y:R;ub:0;mb:0;b:0                       / no bias
y:r-'mb+b+last ub

/ user user collaborative filtering

-1"user-user collaborative filtering fills missing ratings";
-1"with averaged values from users who's ratings are most similar to ours";
-1"we have many choices to make:";
-1"[ ] should we use Pearson's correlation (cor) or Spearman's (.ml.scor)";
-1"[ ] should we use cosine similarity instead?";

k:20
-1"average top ",string[k], "users based on correlation";
p:(mb+b+last ub)+'.ml.fknn[1+0*;.ml.cordist\:;k;Y;Y] (0!y)`rating
show 10#`score xdesc update score:p,movieId.title from r
-1"average top n users based on spearman correlation";
p:(mb+b+last ub)+'.ml.fknn[1+0*;.ml.scordist\:;k;Y;Y] (0!y)`rating
show 10#`score xdesc update score:p,movieId.title from r
-1"weighted average top n users based on cosine similarity";
p:(mb+b+last ub)+'.ml.fknn[1+0*;.ml.cosdist\:;k;Y;Y] (0!y)`rating
show 10#`score xdesc update score:p,movieId.title from r
nf:10;

if[2<count key `.qml;
 -1 .util.box["**"] (
  "singular value decomposition (svd) allows us to compute latent factors (off-line)";
  "and perform simple matrix multiplication to make predictions (on-line)");
 -1"compute score based on top n svd factors";
 
 / singular value decomposition

 usv:.qml.msvd 0^Y;
 -1"predict missing ratings using low rank approximations";
 P:(b+ub)+mb+/:{x$z$/:y} . .ml.nsvd[nf] usv;
 show 10#`score xdesc update score:last P,movieId.title from r;
 -1"compare against existing ratings";
 show 10#`score xdesc select from (update score:last P,movieId.title from r) where not null rating;
 -1"we can use svd to foldin a new user";
 .ml.foldin[.ml.nsvd[500] usv;0b] 0^Y[2];
 -1"or even a new movie";
 .ml.foldin[.ml.nsvd[500] usv;1b;0^Y[;2]];
 -1"what does the first factor look like?";
 show each {(5#x;-5#x)}([]movieId:m idesc usv[2][;0])#mlense.movie;
 -1"how much variance does each factor explain?";
 show .util.plot[40;19;.util.c10;avg] {x%sum x*:x}.qml.mdiag usv 1;
 ];

/ regularized gradient descent

-1 .util.box["**"] (
 "regularized gradient descent collaborative filtering";
 "doesn't need to be filled with default values";
 "and can use regularization");

n:(ni:count R 0;nu:count R) / n items, n users
-1"randomly initialize X and THETA";
xtheta:2 raze/ XTHETA:(X:-1+ni?/:nf#2f;THETA:-1+nu?/:nf#2f)

-1"learn latent factors that best predict existing ratings matrix";
xtheta:first .fmincg.fmincg[100;.ml.cfcostgrad[rf;n;Y];xtheta] / learn

-1"predict missing ratings";
P:(b+ub)+mb+/:.ml.cfpredict . XTHETA:.ml.cfcut[n] xtheta / predictions
show 10#`score xdesc update score:last P,movieId.title from r
-1"compare against existing ratings";
show 10#`score xdesc select from (update score:last P,movieId.title from r) where not null rating

-1"check collaborative filtering gradient calculations";
.util.assert . .util.rnd[1e-6] .ml.checkcfgrad[1e-4;rf;20 5]

/ stochastic regularized gradient descent

-1"randomly initialize X and THETA";
xtheta:2 raze/ XTHETA:(X:-1+ni?/:nf#2f;THETA:-1+nu?/:nf#2f)

-1"use 'where' to find list of coordinates of non-null items";
i:.ml.mwhere not null R
-1"define cost function";
cf:.ml.cfcost[rf;Y] .
-1"define minimization function";
mf:.ml.cfupd1[.05;.2;Y]
-1"keep running mf until improvement is lower than pct limit";

XTHETA:last a:(.ml.converge[.0001]first::).ml.acccost[cf;{x mf/ 0N?flip i}]/(cf;::)@\:XTHETA

-1"predict missing ratings";
P:(b+ub)+mb+/:.ml.cfpredict . XTHETA / predictions
show 10#`score xdesc update score:last P,movieId.title from r
-1"compare against existing ratings";
show 10#`score xdesc select from (update score:last P,movieId.title from r) where not null rating

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

XTHETA:last (.ml.converge[.0001]first@).ml.acccost[cf;.ml.wrals[.01;Y]]/(cf;::)@\:XTHETA

-1"predict missing ratings";
P:(b+ub)+mb+/:.ml.cfpredict . XTHETA / predictions
show 10#`score xdesc update score:last P,movieId.title from r
-1"compare against existing ratings";
show 10#`score xdesc s:select from (update score:last P,movieId.title from r) where not null rating
.util.assert[.03f] .util.rnd[.01] avg exec .ml.mseloss[rating;score] from s
