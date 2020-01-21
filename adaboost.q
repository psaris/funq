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
-1 "run 5 rounds of adaboost";
r:5 (.ml.adaboost[stump;.ml.dtc;t]last::)\ (0f;2 1#1;::)

-1 "check accuracy";
tt:update -1 1 "M"=diagnosis from d.test
.util.assert[.95] .util.rnd[.01] avg tt.diagnosis=signum sum r[;0] * r[;1] .ml.dtc/:\: tt
-1 "plot improvement of accuracy";
show .util.plt (avg tt.diagnosis=) each signum sums r[;0] * r[;1] .ml.dtc/:\: tt;
