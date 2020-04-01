\c 20 100
\l funq.q
\l wdbc.q
\l winequality.q

-1"applying random forest to the wdbc data set";
k:20
d:.util.part[`train`test!3 1;0N?] wdbc.t
-1"bagging grows B decision trees with random sampling (with replacement)";
m:.ml.bag[k;.ml.q45[();::]] d`train
avg d.test.diagnosis=.ml.pbag[k;m] d`test

-1"a random forest grows B decision trees with random sampling (with replacement)";
-1"and a sub-selection of sqrt (for classifiction) of the features at each split";
m:.ml.bag[k;.ml.q45[(1#`maxff)!1#sqrt;::]] d`train
avg d.test.diagnosis=.ml.pbag[k;m] d`test

-1"applying random forest to the winequality data set";
d:.util.part[`train`test!1 1;0N?] winequality.red.t
-1"bagging grows B decision trees with random sampling (with replacement)";
m:.ml.bag[k;.ml.q45[();::]] d`train
.ml.rms d.test.quality-.ml.pbag[k;m] d`test

-1"a random forest grows B decision trees with random sampling (with replacement)";
-1"and a sub-selection of one third (for regression) of the features at each split";
m:.ml.bag[k;.ml.q45[(1#`maxff)!1#%[;3];::]] d`train
.ml.rms d.test.quality-.ml.pbag[k;m] d`test

