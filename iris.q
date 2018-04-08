iris.f:("iris.data";"bezdekIris.data") 0
iris.b:"http://archive.ics.uci.edu/ml/machine-learning-databases/iris/"
.util.download[iris.b;;"";::] iris.f;
iris.XY:150#/:("FFFFS";",") 0: `$iris.f
iris.X:4#iris.XY
iris.y:last iris.Y:-1#iris.XY
iris.t:`species xcols flip `slength`swidth`plength`pwidth`species!iris.XY

