\c 20 100
\l funq.q

/ http://archive.ics.uci.edu/ml/datasets/Pen-Based+Recognition+of+Handwritten+Digits

-1"pen-based recognition of handwritten digits data set";
f:("pendigits.tra";"pendigits.tes")
b:"http://archive.ics.uci.edu/ml/machine-learning-databases/pendigits/"
-1"download the pendigits training and test dataset";
.util.download[b;;"";::] each f;

-1"loading the training data";
y:last X:(17#"x";",") 0: `$f 0
X:-1_X

-1"loading the test data";
yt:last Xt:(17#"x";",") 0: `$f 1
Xt:-1_Xt

k:4
df:`.ml.edist
-1"checking accuracy of using ",string[k], " nearest neigbors and df=", string df;
f:.ml.knn[df;k;y;X]
-1"using .ml.f2nd to peach across the 2nd dimension of Xt";
avg yt=p:.ml.f2nd[f] Xt

-1"computing the accuracy of each digit";
show avg each (p=yt)[i] group yt i:iasc yt

-1"viewing the confusion matrix, we can see 7 is often confused with 1";
show .util.totals[`TOTAL] .ml.cm[yt;p]

ks:1+til 10
-1"compare different choices of k: ", -3!ks;
t:([]k:ks)
t:update mdist:avg yt=.ml.f2nd[.ml.knn[.ml.mdist;k;y;X]] Xt from t
t:update edist:avg yt=.ml.f2nd[.ml.knn[.ml.edist;k;y;X]] Xt from t
show t;

n:5
-1"cross validate with ", string[n], " buckets";
Xs:flip (n;0N)#/:X
ys:(n;0N)#y
e:(.ml.cv[.ml.knn[df;ks];ys;Xs]0N!) peach til n

-1"find k with maximum accuracy";
k:0N!ks .ml.imax avg avg each e

-1"confirm accuracy against test dataset";
f:.ml.knn[df;k;y;X]
avg yt=p:.ml.f2nd[f] Xt

