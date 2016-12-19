\c 20 100
\l funq.q

/ digit recognition

/ download data
f:(
 "train-labels-idx1-ubyte";
 "train-images-idx3-ubyte";
 "t10k-labels-idx1-ubyte";
 "t10k-images-idx3-ubyte")
b:"http://yann.lecun.com/exdb/mnist/"
-1"downloading handwritten numbers dataset";
.util.download[b;;".gz";system 0N!"gunzip -v ",] each f; / download data

-1"loading training data";
Y:enlist y:"i"$.util.ldmnist read1 `$f 0
X:flip "f"$raze each .util.ldmnist read1 `$f 1

-1"define a plot function (which includes the empty space character)";
plt:.plot.plot[28;15;.plot.c10] .plot.hmap flip 28 cut
-1"visualize the data";
-1 value (,') over plt each flip  X[;-4?count X 0];

lbls:til 10
l:1                             / lambda (regularization coefficient)
theta:(1+count X)#0f
mf:(first .fmincg.fmincg[20;;theta]@) / pass minimization func as parameter
cgf:.ml.rlogcostgrad[l;X] / pass cost & gradient function as parameter

-1"to run one-vs-all",$[l;" with regularization";""];
-1"we perform multiple runs of logistic regression (one for each digit)";
-1"this trains one set of parameters for each number";
-1 .util.box["**"] "for performance, we peach across digits";
theta:.ml.onevsall[mf;cgf;Y;lbls]

-1"loading testing data";
Y:enlist y:"i"$.util.ldmnist read1 `$f 2
X:flip "f"$raze each .util.ldmnist read1 `$f 3

-1"checking accuracy of parameters";
avg y=p:.ml.predictonevsall[X] enlist theta

-1"view a few confused characters";
w:where not y=p
do[2;show value plt X[;i:rand w];show ([]p;y) i]

-1"view the confusion matrix";
.util.totals[`TOTAL] .ml.cm[y;"i"$p]

-1"demonstrate a few binary classification evaluation metrics";
-1"how well did we predict the number 8";
tptnfpfn:.ml.tptnfpfn[8=first Y;8=p]
-1"accuracy: ",                                         string .ml.accuracy tptnfpfn;
-1"precision: ",                                        string .ml.precision tptnfpfn;
-1"recall: ",                                           string .ml.recall tptnfpfn;
-1"F1 (harmonic mean between precision and recall): ",  string .ml.F1 tptnfpfn;
-1"FM (geometric mean between precision and recall): ", string .ml.FM tptnfpfn;
-1"jaccard (0 <-> 1 similarity measure): ",             string .ml.jaccard tptnfpfn;
-1"MCC (-1 <-> 1 correlation measure): ",               string .ml.MCC tptnfpfn;

