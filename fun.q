\l ml.q
\l plot.q
\l fmincg.q
\l qml.q
\c 20 100

/ box-muller (copied from qtips/stat.q) (m?-n in k6)
bm:{
 if[count[x] mod 2;'`length];
 x:2 0N#x;
 r:sqrt -2f*log first x;
 theta:2f*acos[-1f]*last x;
 x: r*cos theta;
 x,:r*sin theta;
 x}

download:{[b;f;e;uf]if[()~key`$":",f;(`$":",f)1:.Q.hg`$":",0N!b,f,:e;uf f]}

\
/ define a plotting function
plt:.plot.plot[28;15;1_.plot.c16]

/ plot sin x
plt sin .01*til 1000

/ uniform random variables
plt 100000?1f

/ normal random variables (k6:10000?-1f)
plt bm 10000?1f

/ 2 sets of independant normal random variables
/ NOTE: matrix variables are uppercase
X:(bm 10000?) each 1 1f

/ TIP: suppress the desire to flip matrices

/ Matlab/Octave/R all store data in columns

/ q needs the ability to tag matrices so they can be displayed (not
/ stored) flipped
flip X

/ plot x,y
plt X

/ correlate x and y
rho:.8
X[0]:(rho;sqrt 1f-rho*rho)$X

/ plot correlated x,y
plt X

/ NOTE: use $ for both dot product and matrix multiplication

/ add intercept
.ml.addint X

/ fit a line with intercept
Y:-1#X
X:1#X
show THETA:Y lsq .ml.addint X

/ plot fitted line
plt X,.ml.predict[X] THETA

/ fast but not numerically stable
.ml.mlsq[Y;.ml.addint X]

/ NOTE: use 'X$/:Y' instead of 'Y mmu flip X' to avert flipping large
/ matrices
\ts Y mmu flip X
\ts X$/:Y

/ qml uses QR decomposition for a more numerically stable fit, but it
/ makes us flip both X and Y
\ts flip .qml.mlsq[flip .ml.addint X;flip Y]

/ nice to have closed form solution, but what if we don't?

/ gradient descent
alpha:.1
THETA:1 2#0f
.ml.gd[alpha;.ml.lingrad[X;Y]] THETA

/ n steps
2 .ml.gd[alpha;.ml.lingrad[X;Y]]/ THETA
/ until cost within tolerance
(.4<.ml.lincost[X;Y]@) .ml.gd[alpha;.ml.lingrad[X;Y]]/ THETA
/ until convergence
.ml.gd[alpha;.ml.lingrad[X;Y]] over THETA

/ how to represent a binary outcome?
/ use sigmoid function

plt .ml.sigmoid .1*-50+til 100

/ classification
X:30+100*(100?1f;.01*til 100)
Y:enlist .ml.sigmoid .1*-150+sum X
plt X,Y

/ logistic regression cost
/ NOTE: accepts a list of thetas (in preparation for nn)
THETA: (1;3)#0f;
.ml.logcost[X;Y;enlist THETA]

/ logistic regression gradient
.ml.loggrad[X;Y;enlist THETA]
/ iterate 100000 times
100000 .ml.gd[.0005;.ml.loggrad[X;Y]]/ enlist THETA
/ iterate until cost is less than .5
(.5<.ml.logcost[X;Y]@) .ml.gd[.0005;.ml.loggrad[X;Y]]/ enlist THETA
/ iterate until convergence
/.ml.gd[.0005;.ml.loggrad[X;Y]] over enlist THETA

/ we can use qml and just the cost function to compute gradient
/ and optimal step size

opts:`iter,1000,`full`quiet /`rk`slp`tol,1e-8
/ use cost function only
f:.ml.logcost[X;Y]enlist enlist@
.qml.minx[opts;f;THETA]

/ or compute the result even faster with the most recent version of
/ qml, by passing the gradient function as well
f:.ml.logcostgradf[X;Y]
.qml.minx[opts;f;THETA]

/ but the gradient often shares computations with the cost.  providing
/ a single function that calculates both and a better minimization
/ function makes finding the optimal parameters childs play
/ NOTE: use '\r' to show in-place updates to progress across iterations
THETA:first .fmincg.fmincg[20;.ml.logcostgrad[X;Y];THETA 0]

/ compare plots
plt X,Y
plt X,p:.ml.lpredict[X] enlist THETA

/ binary classification evaluation metrics

tptnfpfn:.ml.tptnfpfn["i"$first Y;"i"$first p]
.ml.accuracy tptnfpfn
.ml.precision tptnfpfn 
.ml.recall tptnfpfn
.ml.F1 tptnfpfn          / harmonic mean between precision and recall
.ml.FM tptnfpfn          / geometric mean between precision and recall
.ml.jaccard tptnfpfn     / 0 <-> 1 similarity measure
.ml.MCC tptnfpfn         / -1 <-> 1 correlation measure

/ digit recognition

/ download data
f:("train-labels-idx1-ubyte";"train-images-idx3-ubyte";"t10k-labels-idx1-ubyte";"t10k-images-idx3-ubyte")
b:"http://yann.lecun.com/exdb/mnist/"
download[b;;".gz";system 0N!"gunzip -v ",] each f; / download data

/ load training data
Y:enlist y:"i"$.ml.ldmnist read1 `$"train-labels-idx1-ubyte"
X:flip "f"$raze each .ml.ldmnist read1 `$"train-images-idx3-ubyte"

/ visualize data
/ redefine plot (to include space)
plt:.plot.plot[28;15;.plot.c10] .plot.hmap flip 28 cut
plt  X[;rand count X 0]

/ learn (one vs all)
lbls:til 10
lambda:1
THETA:(1;1+count X)#0f
mf:(first .fmincg.fmincg[20;;THETA 0]@) / pass minimization func as parameter
cgf:.ml.rlogcostgrad[lambda;X]          / cost gradient function

/ multiple runs of logistic regression (one for each digit)
/ train one set of parameters for each number
/ NOTE: peach across digits
THETA:.ml.onevsall[mf;cgf;Y;lbls]

100*avg y=p:.ml.predictonevsall[X] enlist THETA / what percent did we get correct?

/ what did we get wrong?
p w:where not y=p
plt X[;i:rand w]
([]p;y) i

/ confusion matrix
.ml.totals[`TOTAL] .ml.cm[y;"i"$p]

/ confirm analytic gradient is equal to numeric gradient
.ml.checknngradients[.1f;3 5 3]

/ learn (neural network with 1 hidden layer)
n:784 30 10
YMAT:.ml.diag[last[n]#1f]@\:"i"$y

/ need random weights

theta:2 raze/ .ml.ninit'[-1_n;1_n];

/ batch gradient descent - steepest gradient (might find local minima)
first .fmincg.fmincg[1;.ml.nncost[0f;n;X;YMAT];theta]

/ NOTE: qml throws a `limit error (too many elements)
/ .qml.minx[`quiet`full`iter,1;.ml.nncostf[0f;n;X;YMAT];enlist theta]

/ stochastic gradient descent
/ - jumpy (can find global minima)
/ - converges faster (but might never stop)
/ on-line if n = 1
/ mini-batch if n>1 (vectorize calculations)

mf:{first .fmincg.fmincg[5;.ml.nncost[0f;n;X[;y];YMAT[;y]];x]}

/https://www.quora.com/Whats-the-difference-between-gradient-descent-and-stochastic-gradient-descent
/ A: permutate, run n non-permuted epochs
i:0N?count X 0;X:X[;i];YMAT:YMAT[;i];Y:Y[;i];y:Y 0
theta:1 .ml.sgd[mf;til;10000;X]/ theta
/ B: run n permuted epochs
theta:1 .ml.sgd[mf;0N?;10000;X]/ theta
/ C: run n random (with replacement) epochs (aka bootstrap)
theta:1 .ml.sgd[mf;{x?x};10000;X]/ theta

/ NOTE: can run any above example with cost threshold
theta:(1f<first .ml.nncost[0f;n;X;YMAT]@) .ml.sgd[mf;0N?;10000;X]/ theta

/ what is the total cost?
first .ml.nncost[0f;n;X;YMAT;theta]

/ how well did we learn
100*avg y=p:.ml.predictonevsall[X] .ml.nncut[n] theta

/ visualize hidden features
plt 1_ last first .ml.nncut[n] theta

/ view a few mistakes
p w:where not y=p
plt X[;rw:rand w]
([]p;y) rw

/ load testing data
Yt:enlist yt:"i"$.ml.ldmnist read1 `$"t10k-labels-idx1-ubyte"
Xt:flip "f"$raze each .ml.ldmnist read1 `$"t10k-images-idx3-ubyte"

/ how well can we predict
100*avg yt=p:.ml.predictonevsall[Xt] enlist THETA

/ view a few mistakes
p w:where not yt=p
plt Xt[;rw:rand w]
([]p;yt) rw

/ confusion matrix
.ml.totals[`TOTAL] .ml.cm[yt;"i"$p]

/ clustering

/ redefine plot (to drop space)
plt:.plot.plot[28;15;1_.plot.c10]
k:3 / 3 centroids

show C:"f"$k?/:2#20 / initial centroids
X:raze each C,''C+bm(2;k)#100?/:(2*k)#1f
plt X

/ the number of centroids (k) becomes the actual centroids after the
/ initial iteration
.ml.kmeans[X]\[k]               / euclidian distance

/ NOTE: picks x and y from data (but not necessarily (x;y))
.ml.kmedians[X]\[k]             / manhattan distance (taxicab metric)

/ classic machine learning iris data
f:("iris.data";"bezdekIris.data") 1 / pick the corrected dataset
b:"http://archive.ics.uci.edu/ml/machine-learning-databases/iris/"
download[b;;"";::] f;           / download data
I:value 4#flip iris:150#flip `slength`swidth`plength`pwidth`species!("FFFFS";",") 0: `$f
plt I 3

flip  C:.ml.kmeans[I]/[-3]       / find 3 centroids
show g:.ml.cgroup[.ml.edist;I;C] / classify
100*avg iris.species=distinct[iris.species] .ml.ugrp g / accuracy
.ml.totals[`TOTAL] .ml.cm[iris.species;distinct[iris.species] .ml.ugrp g]


/ plot errors with increasing number of centroids
plt (.ml.distortion .ml.ecdist[I] .ml.kmeans[I]@) each neg 1+til 10

/ cosine similarity (distance)
flip C:.ml.lloyd[.ml.cosdist;avg;I]/[-3] /find 3 centroids
show g:.ml.cgroup[.ml.cosdist;I;C]       / classify
100*avg iris.species=distinct[iris.species] .ml.ugrp g / accuracy

/ hierarchical (agglomerative) clustering analysis (HCA)
l:.ml.linkage[.ml.edist;.ml.ward] I / perform clustering
t:.ml.tree flip 2#l                 / build dendrogram
plt 10#reverse l 2                  / determine optimal number of clusters
g:2 1 0!(raze/) each 2 .ml.slice/ t / cut into 3 clusters
100*avg iris.species=distinct[iris.species] .ml.ugrp g


/ expectation maximization (EM)

/ binomial example
/ http://www.nature.com/nbt/journal/v26/n8/full/nbt1406.html
n:10
x:sum each (1000110101b;1111011111b;1011111011b;1010001100b;0111011101b)
theta: .6 .5                    / initial coefficients
lf:.ml.binla[n]                 / likelihood function
mf:.ml.binml[n]                 / parameter maximization function
/ pass phi as 1 because coins are picked with equal probability
.ml.em[lf;mf;x] (1;theta)
.ml.em[lf;mf;x] over (1;theta)  / call until convergence
.ml.em[lf;mf;x] over 2          / let .ml.em initialize parameters
/ which flips came from which theta? pick maximum log likelkhood
.ml.imax each flip .ml.binll[n;;x] each last .ml.em[lf;mf;x] over (1;theta)

/ gaussian mixtures
/ http://mccormickml.com/2014/08/04/gaussian-mixture-models-tutorial-and-matlab-code/
/ 1d gauss
mu0:10 20 30                    / distribution's mu
s20:s0*s0:1 3 2                 / distribution's variance
m0:100 200 150                  / number of points per distribution
X:raze X0:mu0+s0*(bm ?[;1f]@) each m0 / build dataset
plt raze each (X0;0f*X0),'(X0;.ml.gauss'[mu0;s20;X0]) / plot 1d data and guassian curves
k:count mu0
phi:k#1f%k;                     / guess that distributions occur with equal frequency
mu:neg[k]?X;                    / pick k random points as centers
s2:k#var X;                     / use the whole datasets variance
lf:.ml.gauss                    / likelihood function
mf:.ml.gaussml                  / maximum function
.ml.em[lf;mf;X] over pt:(phi;mu;s2) / returns best guess for (phi;mu;s)
.ml.em[lf;mf;X] over k

/ 2d gauss
mu0:(10 20;-10 -20;0 0)
S20:((30 -20;-20 30);(20 0; 0 50);(10 2; 5 10)) / SIGMA (covariance matrix)
m0:1000 2000 1000

R0:.qml.mchol each S20          / sqrt(SIGMA)
X:(,') over X0:mu0+R0$'(bm (?).)''[flip each flip (m0;3 2#1f)]
plt X

k:count mu0
phi:k#1f%k                      / equal probability
mu:flip X[;neg[k]?count X 0]    / pick k ransom points for mu
S:k#enlist X cov\:/: X          / full covariance matrix

lf:.ml.gaussmv
mf:.ml.gaussmlmv
.ml.em[lf;mf;X] over (phi;mu;S)
.ml.em[lf;mf;X] over k          / let .ml.em initialize parameters

/ lets try the iris data again for >2d

k:count distinct iris`species
phi:k#1f%k                      / equal prior probability
mu:flip I[;neg[k]?count I 0]    / random initialization
S:k#enlist I cov\:/: I          / sample covariance
lf:.ml.gaussmv
mf:.ml.gaussmlmv
.ml.em[lf;mf;I] over (phi;mu;S)
a:.ml.em[lf;mf;I] over k          / let .ml.em initialize parameters
/ how well did it cluster the data?
g:0 1 2!value group .ml.imax each flip lf[;;I]'[a[1];a[2]]
100*avg iris.species=distinct[iris.species] .ml.ugrp g

/ k nearest neighbors

/ pick classification that occurs most frequently
/ from 3 closest points trained on 100 observations
nn:.ml.knn[.ml.edist;3;iris.species i;I@\:i]'[flip I (_')/i:desc -100?count I 0]
100*avg nn=iris.species _/i

/ markov clustering
/ https://www.cs.ucsb.edu/~xyan/classes/CS595D-2009winter/MCL_Presentation2.pdf
sm:.5<.ml.gaussk[I;.5] each flip I / similarity matrix based on gaussian kernel
distinct  where each flip 0< .ml.mcl[2;1.5;10] over sm
/ are there 4 species: http://www.siam.org/students/siuro/vol4/S01075.pdf

/ https://en.wikipedia.org/wiki/Naive_Bayes_classifier
X:(6 5.92 5.58 5.92 5 5.5 5.42 5.75;
 180 190 170 165 100 150 130 150f;
 12 11 12 10 6 8 7 9f)
y:`male`male`male`male`female`female`female`female / classes
Xt:(6 7f;130 190f;8 12f)                           / test data
flip clf:.ml.fitnb[.ml.gaussml;1f;X;y]             / build classifier
flip d:.ml.densitynb[.ml.gauss;clf] Xt             / compute densities
flip .ml.probabilitynb d        / convert densities to probabilities
`female`male~.ml.predictnb d    / make classification predictions
`female`male~.ml.lpredictnb .ml.densitynb[.ml.gaussll;clf] Xt / use log likelihood

/ iris
clf:.ml.fitnb[.ml.gaussml;1f;I;iris.species] / build classifier
d:.ml.densitynb[.ml.gauss;clf] I             / compute densities
flip .ml.probabilitynb d        / convert densities to probabilities
96f~100*avg iris.species=.ml.predictnb d / how good is classification
96f~100*avg iris.species=.ml.lpredictnb .ml.densitynb[.ml.gaussll;clf] I / use log likelihood

/ inf2b-learn-note07-2up.pdf
X:(2 0 0 1 5 0 0 1 0 0 0;       / goal
 0 0 1 0 0 0 3 1 4 0 0;         / tutor
 0 8 0 0 0 1 2 0 1 0 1;         / variance
 0 0 1 8 0 1 0 2 0 0 0;         / speed
 1 3 0 0 1 0 0 0 0 0 7;         / drink
 1 1 3 8 0 0 0 0 1 0 0;         / defence
 1 0 5 0 1 6 1 1 0 0 1;         / performance
 1 0 0 1 9 1 0 2 0 0 0)         / field
Xt:flip(8 0 0 1 7 1 0 1;0 1 3 0 3 0 1 0)
y:(6#`sport),5#`informatics
/ bernoulli
flip clf:.ml.fitnb[.ml.binml[1];1f;0<X;y] / build classifier
flip d:.ml.densitynb[.ml.binla[1];clf] Xt / compute densities
`sport`informatics~.ml.predictnb d        / make classification prediction

/ bernoulli - add one smoothing
flip clf:.ml.fitnb[.ml.binml[2];1f;1+0<X;y]
`sport`informatics~.ml.predictnb .ml.densitynb[.ml.binla[2];clf] Xt
`sport`informatics~.ml.lpredictnb .ml.densitynb[.ml.binll[2];clf] Xt / use log likelihood

/ multinomial - add one smoothing
flip clf:.ml.fitnb[.ml.multiml[1];1f;X;y]
`sport`informatics~.ml.predictnb .ml.densitynb[.ml.multila;clf] Xt
`sport`informatics~.ml.lpredictnb .ml.densitynb[.ml.multill;clf] Xt / use log likelihood

/ https://www.youtube.com/watch?v=km2LoOpdB3A
X:(2 2 1 1; / chinese
 1 0 0 0;   / beijing
 0 1 0 0;   / shanghai
 0 0 1 0;   / macao
 0 0 0 1;   / tokyo
 0 0 0 1)   / japan
y:`c`c`c`j
Xt:flip enlist 3 0 0 0 1 1

/ multinomial - add one smoothing
flip clf:.ml.fitnb[.ml.multiml[1];1f;X;y]
flip d:.ml.densitynb[.ml.multila;clf] Xt
flip .ml.probabilitynb d
(1#`c)~.ml.predictnb d

/2 .ml.em[.ml.multila;.ml.multiml[1];X]/  2

/ decision trees

/ http://www.cise.ufl.edu/~ddd/cap6635/Fall-97/Short-papers/2.htm
/ http://www.saedsayad.com/decision_tree.htm
/ Paper_3-A_comparative_study_of_decision_tree_ID3_and_C4.5.pdf

/ load weather data, remove the day column and move Play to front
tree:.ml.id3 t:`Play xcols (" SSSSS";1#",") 0: `:weather.csv
100*avg t.Play=.ml.dtc[tree] each t / accuracy
71.428571428571431=100*avg t.Play=.ml.dtc[.ml.id3 (1#`Outlook) _ t] each t

/ c4.5
/ change humidity into a continuous variable
t[`Humidity]:85 90 78 96 80 70 65 95 70 80 70 90 75 80
show last last tree:.ml.id3 t / id3 creates bushy tree
show last last tree:.ml.q45[2;neg .qml.nicdf .0] t / 4.5 picks a split value
100*avg t.Play=.ml.dtc[tree] each t / accuracy
/ handle nulls by using the remaining attributes
.ml.dtc[tree] `Outlook`Temperature`Humidity`Wind!(`Rain;`Hot;85;`)

/ sparse matrix
X:"f"$(100;100)#0 0 0 0 0 0 0 1
/ matrix -> sparse -> matrix == matrix
X~.ml.full S:.ml.sparse X
/ sparse matrix multiplication == mmu
(X$X)~.ml.full .ml.smm[S;S]
/ transposition works too
(X$flip X)~.ml.full .ml.smm[S;.ml.sflip S]

/ pagerank
/ http://www.cs.princeton.edu/~chazelle/courses/BIB/pagerank.htm
/ http://www.mathworks.com/help/matlab/examples/use-page-rank-algorithm-to-rank-websites.html
s:"aaabbcddd"
t:"bcddabcab"
S:(1 2#1+max raze 2#S),S:.ml.append[1f] distinct[s,t]?/:(s;t)
X:.ml.full S
s:1 1 2 2 3 3 3 4 5
t:2 5 3 4 4 5 6 1 1
S:(1 2#max s,t), .ml.append[1f] (s;t)-1
X:.ml.full S

/ pagerank matrix inversion
/ https://www.mathworks.com/moler/exm/chapters/pagerank.pdf
.ml.drank .ml.pageranki[.85;X]

/ https://en.wikipedia.org/wiki/PageRank
\ts:1000 .ml.drank .ml.pagerankr[.85;X] over r:n#1f%n:count X

/ https://en.wikipedia.org/wiki/Google_matrix
X:(01100000b;10001000b;01000001b;00100000b;00010001b;00011000b;00010100b;10010010b)
.ml.drank .ml.pageranki[.85;X]     / matrix inversion
.ml.drank .ml.pagerankr[.85;"f"$X] over r:n#1f%n:count X / function iteration
.ml.drank $[;.ml.google[.85;X]] over r:n#1f%n:count X    / non-sparse matrix iteration

s:1 2 3 3 3 4 4
t:2 1 1 3 5 3 5
S:(1 2#max s,t), .ml.append[1f] (s;t)-1
X:.ml.full S
.ml.drank .ml.pageranki[.85;X]
.ml.drank .ml.pagerankr[.85;"f"$X] over r:n#1f%n:count X
.ml.drank $[;.ml.google[.85;X]] over r:n#1f%n:count X

/ collaborative filter (recommender systems)

f:("ml-latest";"ml-latest-small") 1 / pick the smaller dataset
b:"http://files.grouplens.org/datasets/movielens/" / base url
download[b;;".zip";system 0N!"unzip ",] f;         / download data
/ integer movieIds, enumerate genres, link movieId, and store ratings as real to save space
movie:1!update `u#movieId,`genre?/:`$"|" vs' genres from ("I**";1#",") 0: `$":",f,"/movies.csv"
links:1!update `u#`movie$movieId from ("III";1#",") 0: `$":",f,"/links.csv"
rating:update `p#userId,`movie$movieId from ("IIEP";1#",") 0: `$":",f,"/ratings.csv"

/ http://webdam.inria.fr/Jorge/html/wdmch19.html
/ support
exec nuser:count distinct userId, nmovie:count distinct movieId, nrat:count i from rating
/ distribution
select nuser:count userId by nrat from select nrat:20 xbar count rating by userId from rating
select nmovie:count movieId by nrat from select nrat:10 xbar count rating by movieId from rating
/ quality
select avg rating from rating
select nmovie:count i by rating from rating
select nuser:count i by arat from select arat:.5 xbar avg rating by userId from rating
select nmovie:count i by arat from select arat:.5 xbar avg rating by movieId from rating

rat:update 0f^.ml.demean rating by userId from rating / demeaned ratings
/ global picks (notice small # ratings)
select[10;>rating] "h"$avg rating, n:count i by movieId.title from rat
/ most rated movies
select[40;>n] "h"$avg rating, n:count i by movieId.title from rat

/ full ratings matrix
R:value exec (movieId!rating) first flip key movie by userId from rating

plt:.plot.plot[150;39;.plot.c68]
\c 50 200
plt .plot.hmap R

r:1!select movieId,rating:0Ne from movie / initial ratings
r,:([]movieId:260 4006 1968i;rating:5 4 3e)
r,:([]movieId:53996 69526 87520 112370 4006i;rating:5 4 3 2 5e)
select from r,'movie where not null rating  / my ratings

/ http://files.grouplens.org/papers/FnT%20CF%20Recsys%20Survey.pdf

/ user-user collaborative filtering
`score xdesc ,'[;movie] update score:.ml.fzscore[.ml.uucf[cor;.ml.navg[20];0f^.ml.zscore R]0f^] rating from r
`score xdesc ,'[;movie] update score:.ml.fzscore[.ml.uucf[cor;.ml.nwavg[20];0f^.ml.zscore R]0f^] rating from r
`score xdesc ,'[;movie] update score:.ml.fdemean[.ml.uucf[.ml.scor;.ml.nwavg[20];0f^.ml.demean R]0f^] rating from r
`score xdesc ,'[;movie] update score:.ml.fdemean[.ml.uucf[.ml.cossim;.ml.nwavg[20];0f^.ml.demean R]0f^] rating from r

/ compute singular value decomposition (off-line) and make fast
/ predictions (on-line)
usv:.qml.msvd 0f^R-a:avg'[R]
`score xdesc ,'[;movie] update score:.ml.fdemean[last {x$z$/:y} . .ml.foldin[.ml.nsvd[30] usv;;()]0f^] rating from r

/ foldin a new movie
.ml.foldin[.ml.nsvd[30] usv ;();enlist 1f^R[;2]]

/ gradient descent collaborative filtering (doesn't need to be filled
/ with default values and can use regularization)
R,:value[r]`rating
n:(nu:count R;nm:count R 0;nf:20)   / n users, n movies, n features
thetax:2 raze/ (THETA:-1+nu?/:nf#1f;X:-1+nm?/:nf#2f)
a:avg each R                    / normalization data

\ts thetax:first .fmincg.fmincg[50;.ml.rcfcostgrad[10f;R-a;n];thetax] / learn
p:.ml.mtm . THETAX:.ml.cfcut[n] thetax               / predictions
`score xdesc ,'[;movie] update score:last a+p from r / add bias
select from (`score xdesc ,'[;movie] update score:last a+p from r) where not null rating
