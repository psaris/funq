\c 20 100
\l funq.q
\l wdbc.q

/ https://cseweb.ucsd.edu/~yfreund/papers/adaboost.ps

-1"discrete adaboost requires the target feature to have values -1 and 1";
t:update -1 1 "M"=diagnosis from 11#/:wdbc.t
-1"we can then split into train and test partitions";
d:`train`test!.util.part[3 1] t
-1 "building a full tree is perfect on the training data";
tr:.ml.ct[();::] d.train
.util.assert[1f] .util.rnd[.01] avg d.train.diagnosis=.ml.dtc[tr] each d.train
-1 "but not as good on the test data";
.util.assert[.9] .util.rnd[.01] avg d.test.diagnosis=.ml.dtc[tr] each d.test
-1 "how many leaves did we create?";
count .ml.leaves tr
-1 "adaboost creates an ensemble of weak learners to produce a strongn learning";
-1 "a decision stump (tree with one branch) is a good weak learner";
-1 "because it has > 50% accuracy";
stump:.ml.ct[(1#`maxd)!1#1]
-1 "how good is using just a single stump?";
-1 .ml.ptree[0] stump[::] d.train;
-1 "convert wdbc.diagnosis to discrete values -1 and 1";
n:50
-1 "let's run ",string[n]," rounds of adaboost";
m:1_n (.ml.adaboost[stump;.ml.dtc;d.train]last::)\ (::)
p:signum sum m[;1] * m[;0] .ml.dtc/:\: d.train
.util.assert[.98] .util.rnd[.01] avg d.train.diagnosis=p
-1 "plot the improvement to accuracy on the training set as we increase the ensemble size";
P:signum sums m[;1] * m[;0] .ml.dtc/:\: d.train
show .util.plt (avg d.train.diagnosis=) each P

-1 "but how does each extra stump help in predicting the test set?";
pt:signum sum m[;1] * m[;0] .ml.dtc/:\: d.test
.util.assert[.97] .util.rnd[.01] avg d.test.diagnosis=pt
-1 "we can also plot the improvement to accuracy on the test set as we increase the ensemble size";
Pt:signum sums m[;1] * m[;0] .ml.dtc/:\: d.test
show .util.plt (avg d.test.diagnosis=) each Pt
