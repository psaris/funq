\c 20 100
\l funq.q
\l mnist.q

/ digit recognition

-1"referencing mnist data from global namespace";
`X`Xt`Y`y`yt set' mnist`X`Xt`Y`y`yt;
-1"shrinking training set";
X:1000#'X;Y:1000#'Y;y:1000#y;
X%:255f;Xt%:255f

-1"define a plot function that includes the empty space character";
plt:value .util.plot[28;14;.util.c10;avg] .util.hmap flip 28 cut
-1"visualize the data";
-1 (,'/) plt each X@\:/: -4?count X 0;

lbls:"i"$til 10
rf:.ml.l2[1]                    / regularization function
theta:(1+count X)#0f            / initial theta coefficients

f:first .fmincg.fmincg[5;;theta] .ml.logcostgrad[rf;;X]@

-1"to run one-vs-all",$[count rf;" with regularization";""];
-1"we perform multiple runs of logistic regression (one for each digit)";
-1"this trains one set of parameters for each number";
-1 .util.box["**"] "for performance, we peach across digits";
THETA:.ml.fova[f;Y;lbls]

-1"checking accuracy of parameters";
avg yt=p:lbls .ml.imax .ml.plog[Xt] THETA

-1"view a few confused characters";
w:where not yt=p
do[2;-1 plt Xt[;i:rand w];show ([]p;yt) i]

-1"view the confusion matrix";
show .util.totals[`TOTAL] .ml.cm[yt;p]
