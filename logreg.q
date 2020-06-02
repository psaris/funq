\c 20 100
\l funq.q
\l wdbc.q

-1"partitioning wdbc data into train and test";
show d:.util.part[`train`test!3 1;0N?] "f"$update "M"=diagnosis from wdbc.t
YX:value flip d`train
y:first Y:1#YX
X:1_YX
YXt:value flip d`test
yt:first Yt:1#YXt
Xt:1_YXt

-1"the sigmoid function is used to represent a binary outcome";
plt:.util.plot[30;15;.util.c10;sum]
show plt .ml.sigmoid .1*-50+til 100

/ logistic regression cost
-1"to use gradient descent, we must first define a cost function";
THETA:enlist theta:(1+count X)#0f;
-1"compute cost of initial theta estimate";
.ml.logcost[();Y;X;THETA]

if[2<count key `.qml;
 -1"qml comes with a minimizer that can be called";
 -1"with just this cost function:";
 opts:`iter,1000,`full`quiet; /`rk`slp`tol,1e-8
 0N!first 1_.qml.minx[opts;.ml.logcost[();Y;X]enlist::;THETA];
 ];

-1"we can also define a gradient function to make this process faster";
.ml.loggrad[();Y;X;THETA]

-1"check that we've implemented the gradient correctly";
rf:.ml.l2[1]
cf:.ml.logcost[rf;Y;X]enlist::
gf:first .ml.loggrad[rf;Y;X]enlist::
.util.assert . .util.rnd[1e-6] .ml.checkgrad[1e-4;cf;gf;theta]
cgf:.ml.logcostgrad[rf;Y;X]
cf:first cgf::
gf:last cgf::
.util.assert . .util.rnd[1e-6] .ml.checkgrad[1e-4;cf;gf;theta]


if[2<count key `.qml;
 -1"qml can also use both the cost and gradient to improve performance";
 0N!first 1_.qml.minx[opts;.ml.logcostgradf[();Y;X];THETA];
 ];

-1"but the gradient calculation often shares computations with the cost";
-1"providing a single function that calculates both is more efficient";
-1".fmincg.fmincg (function minimization conjugate gradient) permits this";

-1 .util.box["**"]"use '\\r' to create a progress bar with in-place updates";

theta:first .fmincg.fmincg[1000;.ml.logcostgrad[();Y;X];theta]

-1"compute cost of initial theta estimate";
.ml.logcost[();Y;X;enlist theta]

-1"test models accuracy";
avg yt="i"$p:first .ml.plog[Xt;enlist theta]

-1"lets add some regularization";
theta:(1+count X)#0f;
theta:first .fmincg.fmincg[1000;.ml.logcostgrad[.ml.l1[10];Y;X];theta]

-1"test models accuracy";
avg yt="i"$p:first .ml.plog[Xt;enlist theta]

show .util.totals[`TOTAL] .ml.cm["i"$yt;"i"$p]

-1"demonstrate a few binary classification evaluation metrics";
-1"how well did we fit the data";
tptnfpfn:.ml.tptnfpfn . "i"$(yt;p)
-1"accuracy: ",                                         string .ml.accuracy . tptnfpfn;
-1"precision: ",                                        string .ml.precision . tptnfpfn;
-1"recall: ",                                           string .ml.recall . tptnfpfn;
-1"F1 (harmonic mean between precision and recall): ",  string .ml.f1 . tptnfpfn;
-1"FMI (geometric mean between precision and recall): ", string .ml.fmi . tptnfpfn;
-1"jaccard (0 <-> 1 similarity measure): ",             string .ml.jaccard . tptnfpfn;
-1"MCC (-1 <-> 1 correlation measure): ",               string .ml.mcc . tptnfpfn;

-1"plot receiver operating characteristic (ROC) curve";
show .util.plt roc:2#.ml.roc . (yt;p)
-1"area under the curve (AUC)";
.ml.auc . 2#roc
fprtprf:(0 0 .5 .5 1;0 .5 .5 1 1;0w .8 .4 .35 .1)
-1"confirm accurate roc results";
.util.assert[fprtprf] .ml.roc . (0 0 1 1;.1 .4 .35 .8)
-1"use random values to confirm large vectors don't explode memory";
y:100000?0b
p:100000?1f
show .util.plt roc:2#.ml.roc . (y;p)
-1"confirm auc for random data is .5";
.util.assert[.5] .util.rnd[.01] .ml.auc . roc
