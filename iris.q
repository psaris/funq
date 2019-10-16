iris.f:("iris.data";"bezdekIris.data") 1
iris.b:"http://archive.ics.uci.edu/ml/machine-learning-databases/"
iris.b,:"iris/"
-1"[down]loading iris data set";
.util.download[iris.b;;"";""] iris.f;
iris.XY:150#/:("FFFFS";",") 0: `$iris.f
iris.X:-1_iris.XY
iris.y:first iris.Y:-1#iris.XY
iris.c:`slength`swidth`plength`pwidth`species
iris.t:`species xcols flip iris.c!iris.XY

