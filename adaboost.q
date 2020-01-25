\c 20 100
\l funq.q
\l wdbc.q

/ https://cseweb.ucsd.edu/~yfreund/papers/adaboost.ps

d:`train`test!.util.part[3 1] 11#/:wdbc.t
-1 "build a full treea";
tr:.ml.ct[();::] d`train
-1 "confirm accuracy is perfect";
.util.assert[.9] .util.rnd[.01] avg d.test.diagnosis=.ml.dtc[tr] each d.test
-1 "how many leaves did we create?";
count .ml.leaves tr
-1 "a stump is a single branch tree";
stump:.ml.ct[(1#`maxd)!1#1]
-1 "how good is using just a single stump?";
-1 .ml.ptree[0] stump[::] d.train;
-1 "convert wdbc.diagnosis to discrete values -1 and 1";
t:update -1 1 "M"=diagnosis from d.train
n:50
-1 "run ",string[n]," rounds of adaboost";
r:1_n (.ml.adaboost[stump;.ml.dtc;t]last::)\ (::)
.util.assert[1f] avg t.diagnosis=signum sum r[;1] * r[;0] .ml.dtc/:\: t
-1 "plot the improvement to accuracy on the training set as we increase the ensemble size";
show .util.plt (avg t.diagnosis=) each signum sums r[;1] * r[;0] .ml.dtc/:\: t

-1 "but how does each extra stump help in predicting the test set?";
tt:update -1 1 "M"=diagnosis from d.test
.util.assert[.96] .util.rnd[.01] avg tt.diagnosis=signum sum r[;1] * r[;0] .ml.dtc/:\: tt
-1 "we can also plot the improvement to accuracy on the test set as we increase the ensemble size";
show .util.plt (avg tt.diagnosis=) each signum sums r[;1] * r[;0] .ml.dtc/:\: tt
