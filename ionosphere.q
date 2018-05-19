ionosphere.f:"ionosphere.data"
ionosphere.b:"http://archive.ics.uci.edu/ml/machine-learning-databases/ionosphere/"
-1"downloading ionosphere data set";
.util.download[ionosphere.b;;"";""] ionosphere.f
ionosphere.XY:((34#"E"),"C";",")0:`$ionosphere.f
ionosphere.X:-1_ionosphere.XY
ionosphere.y:first ionosphere.Y:-1#ionosphere.XY
