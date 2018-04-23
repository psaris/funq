wdbc.f:"wdbc.data"
wdbc.b:"http://archive.ics.uci.edu/ml/machine-learning-databases/breast-cancer-wisconsin/"
-1"downloading wisconsin diagnostic breast cancer data set";
.util.download[wdbc.b;;"";::] wdbc.f
wdbc.XY:(" C",30#"E";",") 0: `$wdbc.f
wdbc.X:1_wdbc.XY
wdbc.y:first wdbc.Y:1#wdbc.XY
wdbc.c:`radius`texture`perimeter`area`smoothness`compactness`concavity
wdbc.c,:`concave_points`symmetry`fractal_dimension
wdbc.c:raze `$"_" sv'string raze wdbc.c,\:/:  `mean`se`worst
wdbc.t:flip (`diagnosis,wdbc.c)!wdbc.XY
