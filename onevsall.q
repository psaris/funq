\c 20 100
\l funq.q
\l mnist.q

/ digit recognition

-1"referencing mnist data from global namespace";
`X`Xt`Y`y`yt set' mnist`X`Xt`Y`y`yt;

-1"define a plot function (which includes the empty space character)";
plt:.util.plot[28;14;.util.c10] .util.hmap flip 28 cut
-1"visualize the data";
-1 value (,') over plt each flip  X[;-4?count X 0];

lbls:til 10
l:1                             / lambda (regularization coefficient)
theta:(1+count X)#0f
mf:(first .fmincg.fmincg[5;;theta]@) / pass minimization func as parameter
cgf:.ml.rlogcostgrad[l;X] / pass cost & gradient function as parameter

-1"to run one-vs-all",$[l;" with regularization";""];
-1"we perform multiple runs of logistic regression (one for each digit)";
-1"this trains one set of parameters for each number";
-1 .util.box["**"] "for performance, we peach across digits";
theta:.ml.onevsall[mf;cgf;Y;lbls]

-1"checking accuracy of parameters";
avg yt=p:.ml.predictonevsall[Xt] enlist theta

-1"view a few confused characters";
w:where not yt=p
do[2;show value plt Xt[;i:rand w];show ([]p;yt) i]

-1"view the confusion matrix";
.util.totals[`TOTAL] .ml.cm[yt;"i"$p]

-1"demonstrate a few binary classification evaluation metrics";
-1"how well did we predict the number 8";
tptnfpfn:.ml.tptnfpfn . 8=(yt;p)
-1"accuracy: ",                                         string .ml.accuracy . tptnfpfn;
-1"precision: ",                                        string .ml.precision . tptnfpfn;
-1"recall: ",                                           string .ml.recall . tptnfpfn;
-1"F1 (harmonic mean between precision and recall): ",  string .ml.F1 . tptnfpfn;
-1"FM (geometric mean between precision and recall): ", string .ml.FM . tptnfpfn;
-1"jaccard (0 <-> 1 similarity measure): ",             string .ml.jaccard . tptnfpfn;
-1"MCC (-1 <-> 1 correlation measure): ",               string .ml.MCC . tptnfpfn;

