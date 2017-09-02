\c 20 100
\l funq.q

/ http://archive.ics.uci.edu/ml/datasets/Pen-Based+Recognition+of+Handwritten+Digits

-1"pen-based recognition of handwritten digits data set";
f:("pendigits.tra";"pendigits.tes")
b:"http://archive.ics.uci.edu/ml/machine-learning-databases/pendigits/"
-1"download the pendigits training and test dataset";
.util.download[b;;"";::] each f;

-1"loading the training data";
y:last X:(17#"h";",") 0: `$f 0
X:-1_X

-1"loading the test data";
yt:last Xt:(17#"h";",") 0: `$f 1
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

-1"compare different choices of k ";
t:([]k:1+til 10)
t:update mdist:avg yt=.ml.f2nd[.ml.knn[.ml.mdist;k;y;X]] Xt from t
t:update edist:avg yt=.ml.f2nd[.ml.knn[.ml.edist;k;y;X]] Xt from t
show t;