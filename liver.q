liver.f:"bupa.data"
liver.b:"http://archive.ics.uci.edu/ml/machine-learning-databases/liver-disorders/"
-1"[down]loading liver data set";
.util.download[liver.b;;"";""] liver.f;
liver.XY:((6#"E"),"H";",")0:`$liver.f
liver.X:-1_liver.XY
liver.c:`mcv`alkphos`sgpt`sgot`gammagt`drinks`train
liver.t:flip liver.c!liver.XY
