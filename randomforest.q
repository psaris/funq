\c 20 100
\l funq.q
\l wdbc.q
\l winequality.q

-1"applying random forest to the wdbc data set";
d:`train`test!.util.part[3 1] wdbc.t
-1"bagging grows B decision trees with random sampling (with replacement)";
m:.ml.bag[20;.ml.q45[1;0W;::;::]] d`train
avg d.test.diagnosis=.ml.mode each m .ml.dtc\:/: d`test

-1"a random forest grows B decision trees with random sampling (with replacement)";
-1"and a sub-selection of sqrt (for classifiction) of the features at each split";
m:.ml.bag[20;.ml.q45[1;0W;sqrt::;::]] d`train
avg d.test.diagnosis=.ml.mode each m .ml.dtc\:/: d`test

-1"applying random forest to the winequality data set";
d:`train`test!.util.part[1 1] winequality.red.t
-1"bagging grows B decision trees with random sampling (with replacement)";
m:.ml.bag[20;.ml.q45[1;0W;::;::]] d`train
.ml.rms d.test.quality-avg each m .ml.dtc\:/: d`test

-1"a random forest grows B decision trees with random sampling (with replacement)";
-1"and a sub-selection of one third (for regression) of the features at each split";
m:.ml.bag[20;.ml.q45[1;0W;%[;3]::;::]] d`train
.ml.rms d.test.quality-avg each m .ml.dtc\:/: d`test
