\c 20 100
\l funq.q

f:"OnlineNewsPopularity"
b:"http://archive.ics.uci.edu/ml/machine-learning-databases/00332/"
-1"downloading handwritten online news popularity data set";
.util.download[b;;".zip";system 0N!"unzip -n ",] f;

t:(" efefebebfi" where 2 2 3 4 1 1 6 12 8 21 1;1#",") 0: `$f,"/",f,".csv"
t:`popular xcols delete shares from update popular:shares>=1400 from t;

-1"bagging grows B decision trees with a random sampling (with replacement) of data";
m:.ml.bag[10;.ml.q45[2;0W;::]] 500?t
avg t.popular=.ml.mode each m .ml.dtc\:/: t

-1"a random forest grows B decision trees with a random sampling of data and p features";
m:.ml.rfo[10;floor sqrt count cols t;.ml.q45[2;0W;::]] 500?t
avg t.popular=.ml.mode each m .ml.dtc\:/: t
