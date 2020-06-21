dji.f:"dow_jones_index"
dji.b:"http://archive.ics.uci.edu/ml/machine-learning-databases/"
dji.b,:"00312/"
-1"[down]loading dji data set";
.ut.download[dji.b;;".zip";.ut.unzip] dji.f;
dji.t:("HSDEEEEJFFJEEFHF";1#",")0: ssr[;"$";""] each read0 `$dji.f,".data"
