\c 20 100
\l funq.q
\l wdbc.q

-1"partitioning wdbc data into train and test";
show d:`train`test!.ml.part[3 1] "f"$update "M"=diagnosis from wdbc.t
YX:value flip d`train
y:first Y:1#YX
X:1_YX
YXt:value flip d`test
yt:first Yt:1#YXt
Xt:1_YXt

-1"the sigmoid function is used to represent a binary outcome";
plt:.util.plot[30;15;.util.c10]
show plt .ml.sigmoid .1*-50+til 100

/ logistic regression cost
-1"to use gradient descent, we must first define a cost function";
THETA:enlist theta:(1+count X)#0f;
-1"compute cost of initial theta estimate";
.ml.logcost[X;Y;THETA]

if[2<count key `.qml;
 -1"qml comes with a minimizer that can be called";
 -1"with just this cost function:";
 opts:`iter,1000,`full`quiet; /`rk`slp`tol,1e-8
 0N!first 1_.qml.minx[opts;.ml.logcost[X;Y]enlist::;THETA];
 ];

-1"we can also define a gradient function to make this proces faster";
.ml.loggrad[X;Y;THETA]

if[2<count key `.qml;
 -1"qml can also use both the cost and gradient to improve performance";
 0N!first 1_.qml.minx[opts;.ml.logcostgradf[X;Y];THETA];
 ];

-1"but the gradient calculation often shares computations with the cost";
-1"providing a single function that calculates both is more efficient";
-1".fmincg.fmincg (function minimization conjugate gradient) permits this";

-1 .util.box["**"]"use '\\r' to create a progress bar with in-place updates";

theta:first .fmincg.fmincg[1000;.ml.logcostgrad[X;Y];theta]

-1"compute cost of initial theta estimate";
.ml.logcost[X;Y;enlist theta]

-1"test models accuracy";
avg yt="i"$p:first .ml.lpredict[Xt;enlist theta]

-1"lets add some regularization";
theta:(1+count X)#0f;
theta:first .fmincg.fmincg[1000;.ml.rlogcostgrad[10;0;X;Y];theta]

-1"test models accuracy";
avg yt=p:"i"$first .ml.lpredict[Xt;enlist theta]

show .util.totals[`TOTAL] .ml.cm["i"$yt;p]

-1"demonstrate a few binary classification evaluation metrics";
-1"how well did we fit the data";
tptnfpfn:.ml.tptnfpfn . (yt;p)
-1"accuracy: ",                                         string .ml.accuracy . tptnfpfn;
-1"precision: ",                                        string .ml.precision . tptnfpfn;
-1"recall: ",                                           string .ml.recall . tptnfpfn;
-1"F1 (harmonic mean between precision and recall): ",  string .ml.F1 . tptnfpfn;
-1"FM (geometric mean between precision and recall): ", string .ml.FM . tptnfpfn;
-1"jaccard (0 <-> 1 similarity measure): ",             string .ml.jaccard . tptnfpfn;
-1"MCC (-1 <-> 1 correlation measure): ",               string .ml.MCC . tptnfpfn;
