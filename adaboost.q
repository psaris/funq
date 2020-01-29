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
k:50
-1 "let's run ",string[k]," rounds of adaboost";
m:.ml.fitab[k;stump;.ml.dtc] d.train
p:.ml.clfab[k;.ml.dtc;m] d.train
.util.assert[.98] .util.rnd[.01] avg d.train.diagnosis=p
-1 "plot the improvement to accuracy on the training set as we increase the ensemble size";
P:.ml.clfab[1+til k;.ml.dtc;m] d.train
show .util.plt (avg d.train.diagnosis=) each P

-1 "but how does each extra stump help in predicting the test set?";
pt:.ml.clfab[k;.ml.dtc;m] d.test
.util.assert[.97] .util.rnd[.01] avg d.test.diagnosis=pt
-1 "we can also plot the improvement to accuracy on the test set as we increase the ensemble size";
Pt:.ml.clfab[1+til k;.ml.dtc;m] d.test
show .util.plt (avg d.test.diagnosis=) each Pt

-1 "the number of elements in our ensemble should be decided by cross validation";
ks:1+til 20

n:10
-1"cross validate with ", string[n], " buckets";
ts:.util.part[n#1] t
ff:.ml.fitab[;stump;.ml.dtc]
pf:.ml.clfab[;.ml.dtc]
e:ts[;`diagnosis]=flip each P:.ml.kfxvt[ff ks;pf ks;ts] peach til n

-1"find k with maximum accuracy";
k:0N!ks .ml.imax avg avg each e

-1"confirm accuracy against test dataset";
avg d.test.diagnosis = pf[k;;d.test] ff[k] d.train
