wine.f:"wine.data"
wine.b:"http://archive.ics.uci.edu/ml/machine-learning-databases/"
wine.b,:"wine/"
-1"[down]loading wine data set";
.util.download[wine.b;;"";""] wine.f;
wine.XY:("H",13#"E";",")0:`$wine.f
wine.X:1_wine.XY
wine.y:first wine.Y:1#wine.XY
wine.c:`class`alcohol`malic_acid`ash`alcalinity_of_ash`magnesium
wine.c,:`total_phenols`flavanoids`nonflavanoid_phenols`proanthocyanins
wine.c,:`color_intensity`hue`OD280_OD315`proline
wine.t:flip wine.c!wine.XY
