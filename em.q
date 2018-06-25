\c 40 100
\l funq.q

/ expectation maximization (EM)

/ binomial example
/ http://www.nature.com/nbt/journal/v26/n8/full/nbt1406.html
n:10
x:sum each (1000110101b;1111011111b;1011111011b;1010001100b;0111011101b)
theta: flip enlist .6 .5        / initial coefficients
lf:.ml.binla[n]                 / likelihood function
mf:.ml.binml[n]                 / parameter maximization function
/ pass phi as 1 because coins are picked with equal probability
.ml.em[lf;mf;x] (1;theta)
.ml.em[lf;mf;x] over (1;theta)  / call until convergence
.ml.em[lf;mf;x] over 2          / let .ml.em initialize parameters
/ which flips came from which theta? pick maximum log likelkhood
.ml.f2nd[.ml.imax] (@[;x] .ml.binll[n] .) peach last .ml.em[lf;mf;x] over (1;theta)

/ gaussian mixtures
/ http://mccormickml.com/2014/08/04/gaussian-mixture-models-tutorial-and-matlab-code/
/ 1d gauss
mu0:10 20 30                    / distribution's mu
s20:s0*s0:1 3 2                 / distribution's variance
m0:100 200 150                  / number of points per distribution
X:raze X0:mu0+s0*(.util.bm ?[;1f]@) each m0 / build dataset
show .util.plt raze each (X0;0f*X0),'(X0;.ml.gauss'[mu0;s20;X0]) / plot 1d data and guassian curves
k:count mu0
phi:k#1f%k;      / guess that distributions occur with equal frequency
mu:neg[k]?X;     / pick k random points as centers
s2:k#var X;      / use the whole datasets variance
lf:.ml.gauss     / likelihood function
mf:.ml.gaussml   / maximum function
.ml.em[lf;mf;X] over pt:(phi;flip (mu;s2)) / returns best guess for (phi;mu;s)
.ml.em[lf;mf;X] over k

/ 2d gauss
mu0:(10 20;-10 -20;0 0)
S20:((30 -20;-20 30);(20 0; 0 50);(10 2; 5 10)) / SIGMA (covariance matrix)
m0:1000 2000 1000

R0:.qml.mchol each S20          / sqrt(SIGMA)
X:(,') over X0:mu0+R0$'(.util.bm (?).)''[flip each flip (m0;3 2#1f)]
show .util.plt X

k:count mu0
phi:k#1f%k                      / equal probability
mu:X@\:/:neg[k]?count X 0       / pick k random points for mu
S:k#enlist X cov\:/: X          / full covariance matrix

lf:.ml.gaussmv
mf:.ml.gaussmlmv
.ml.em[lf;mf;X] over (phi;flip (mu;S))
.ml.em[lf;mf;X] over k          / let .ml.em initialize parameters

/ lets try the iris data again for >2d

\l iris.q
`X`y set' iris`X`y;
k:count distinct y              / 3 clusters
phi:k#1f%k                      / equal prior probability
mu:X@\:/:neg[k]?count y         / pick k random points for mu
S:k#enlist X cov\:/: X          / sample covariance
lf:.ml.gaussmv
mf:.ml.gaussmlmv
.ml.em[lf;mf;X] over (phi;flip (mu;S))
a:.ml.em[lf;mf;X] over k        / let .ml.em initialize parameters
/ how well did it cluster the data?
g:0 1 2!value group .ml.f2nd[.ml.imax] (@[;X]lf .) peach a 1
show m:.ml.mode each y g
avg y=m .ml.ugrp g
-1"what does the confusion matrix look like?";
show .util.totals[`TOTAL] .ml.cm[y;m .ml.ugrp g]
