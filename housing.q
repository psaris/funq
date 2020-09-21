housing.f:"housing.data"
housing.b:"http://archive.ics.uci.edu/ml/machine-learning-databases/"
housing.b,:"housing/"
-1"[down]loading housing data set";
.ut.download[housing.b;;"";""] housing.f;
housing.c:`crim`zn`indus`chas`nox`rm`age`dis`rad`tax`ptratio`b`lstat`medv
housing.tw:("FFFBFFFFHFFFFF";8 7 8 3 8 8 7 8 4 7 7 7 7 7)
housing.t:`medv xcols flip housing.c!housing.tw 0: `$housing.f
housing[`Y`X]:0 1 cut value flip housing.t
housing.y:first housing.Y
