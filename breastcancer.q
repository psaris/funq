\c 20 100
\l funq.q
\l wdbc.q

-1 "building a classification tree (a la scikit learn)";
-1 last .ml.ptree[0] tree:.ml.ct[2;0W;::] wdbc.t;
-1 "building a classification tree (a la quinlan)";
-1 last .ml.ptree[0] tree:.ml.q45[2;0W;::] wdbc.t; / quinlan classification tree
-1 "pruning tree";
-1 last .ml.ptree[0] .ml.prune[.ml.perr[neg .qml.nicdf .000001]] tree;


-1 "splitting train/test";
d:`train`test!(floor .75*count wdbc.t) cut 0N?wdbc.t
-1 "growing a random forest";
m:.ml.rfo[10;floor sqrt count cols t;.ml.ct[2;0W;::]] d`train
-1 "generating predictions";
avg d.test.diagnosis=p:.ml.mode each m .ml.dtc\:/: d`test
-1 "demonstrating confusion matrix";
show .util.totals[`TOTAL] .ml.cm[d.test.diagnosis;p]
