\c 20 100
\l funq.q

f:"OnlineNewsPopularity"
b:"http://archive.ics.uci.edu/ml/machine-learning-databases/00332/"
-1"downloading handwritten online news popularity data set";
.util.download[b;;".zip";system 0N!"unzip ",] f;

t:`shares xcols (" efefebebfi" where 2 2 3 4 1 1 6 12 8 21 1;1#",") 0: `$f,"/",f,".csv"

-1"bagging grows B decision trees with a random sampling of data";
m:.ml.bag[10;.ml.q45[2;0W;0;::]] s:500#t
avg s.shares=.ml.mode each m .ml.dtc\:/: s

-1"a random forest grows B decision trees with a random sampling of data and p features";
m:.ml.rfo[1000;floor sqrt count cols s;.ml.q45[2;0W;0;::]] s:500#t
avg s.shares=.ml.mode each m .ml.dtc\:/: s
