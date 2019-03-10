winequality.f:`red`white!("winequality-red.csv";"winequality-white.csv")
winequality.b:"http://archive.ics.uci.edu/ml/machine-learning-databases/wine-quality/"
-1"downloading wine quality data set";
.util.download[winequality.b;;"";""] each winequality.f;
.winequality.load:{[f]
 YX:value flip t:`quality xcols .Q.id (12#"F";1#";")0:f;
 d:`YX`X`Y`y`t!(YX;1_YX;1#YX;YX 0;t);
 d}
winequality,:.winequality.load each `$winequality.f
