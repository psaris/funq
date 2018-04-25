onp.f:"OnlineNewsPopularity"
onp.b:"http://archive.ics.uci.edu/ml/machine-learning-databases/00332/"
-1"downloading handwritten online news popularity data set";
.util.download[onp.b;;".zip";"unzip -n"] onp.f;

onp.t:(" efefebebfi" where 2 2 3 4 1 1 6 12 8 21 1;1#",") 0: `$onp.f,"/",onp.f,".csv"
onp.t:`popular xcols delete shares from update popular:shares>=1400 from onp.t;

