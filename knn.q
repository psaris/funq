\c 20 100
\l funq.q
\l pendigits.q

k:4
df:`.ml.edist
-1"checking accuracy of using ",string[k], " nearest neigbors and df=", string df;
-1"using .ml.f2nd to peach across the 2nd dimension of Xt - weighting by distance";
avg pendigits.yt=p:.ml.knn[::;k;pendigits.y] d:.ml.f2nd[df pendigits.X] pendigits.Xt
-1"using pairwise distance (squared) function - weighting by distance";
avg pendigits.yt=p:.ml.knn[sqrt;k;pendigits.y] d:.ml.pedist2[pendigits.X;pendigits.Xt]

-1"computing the accuracy of each digit";
show avg each (p=pendigits.yt)[i] group pendigits.yt i:iasc pendigits.yt
-1"viewing the confusion matrix, we can see 7 is often confused with 1";
show .util.totals[`TOTAL] .ml.cm[pendigits.yt;p]

ks:1+til 10
-1"compare different choices of k: ", -3!ks;
t:([]k:ks)
t:update mdist:avg pendigits.yt=.ml.knn[::;k;pendigits.y] .ml.f2nd[.ml.mdist pendigits.X] pendigits.Xt from t
t:update edist:avg pendigits.yt=.ml.knn[::;k;pendigits.y] .ml.f2nd[.ml.edist pendigits.X] pendigits.Xt from t
show t;

n:5
-1"cross validate with ", string[n], " buckets";
Xs:flip (n;0N)#/:pendigits.X
ys:(n;0N)#pendigits.y
e:(.ml.cv[{.ml.knn[sqrt;ks;x] .ml.pedist2[y;z]};ys;Xs]0N!) peach til n

-1"find k with maximum accuracy";
k:0N!ks .ml.imax avg avg each e

-1"confirm accuracy against test dataset";
f:.ml.knn[sqrt;k;pendigits.y] .ml.pedist2[pendigits.X]@
avg pendigits.yt=p:f pendigits.Xt
