\c 20 100
\l funq.q

-1"the sigmoid function is used to represent a binary outcome";
plt:.plot.plot[28;15;1_.plot.c10]
show plt .ml.sigmoid .1*-50+til 100

-1"logistic regression can be used to discretely classify data";
f:"binary.csv"
b:"http://www.ats.ucla.edu/stat/data/"
.util.download[b;;"";::] f
t:("BIFI";1#",") 0: `$f
Y:"f"$1#value flip t
X:"f"$1_value flip t
show plt (2#X),Y

.ml.cm[t.admit;t.rank]

/ logistic regression cost
-1"to use gradient descent, we must first define a cost function";
theta: 4#4?0f;
-1"compute cost of initial theta estimate";
.ml.logcost[X;Y;theta]

if[`qml in key`;
 -1"qml comes with a minimizer that can be called";
 -1"with just this cost function:";
 opts:`iter,1000,`full`quiet; /`rk`slp`tol,1e-8
 0N!first 1_.qml.minx[opts;.ml.logcost[X;Y];enlist theta];
 ];

-1"we can also define a gradient function to make this proces faster";
.ml.loggrad[X;Y;theta]

if[`qml in key `;
 -1"qml can also use both the cost and gradient to improve performance";
 0N!first 1_.qml.minx[opts;.ml.logcostgradf[X;Y];enlist theta];
 ];

-1"but the gradient calculation often shares computations with the cost";
-1"providing a single function that calculates both is more efficient";
-1".fmincg.fmincg (function minimization conjugate gradient) permits this";

-1 .util.box["**"]"use '\\r' to create a progress bar with in-place updates";

theta:first .fmincg.fmincg[1000;.ml.logcostgrad[X;Y];theta]

/ compare plots
show plt X,Y;
show plt X,p:.ml.lpredict[X] enlist theta;
