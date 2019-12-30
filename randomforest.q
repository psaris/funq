\c 20 100
\l funq.q
\l wdbc.q

d:`train`test!.util.part[3 1] wdbc.t
-1"bagging grows B decision trees with a random sampling (with replacement) of data";
m:.ml.bag[10;.ml.q45[1;0W;::]] d`train
avg d.test.diagnosis=.ml.mode each m .ml.dtc\:/: d`test

-1"a random forest grows B decision trees with a random sampling of data and p features";
m:.ml.rfo[10;floor sqrt count cols d`train;.ml.q45[1;0W;::]] d`train
avg d.test.diagnosis=.ml.mode each m .ml.dtc\:/: d`test
