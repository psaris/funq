seeds.f:"seeds_dataset.txt"
seeds.b:"http://archive.ics.uci.edu/ml/machine-learning-databases/"
seeds.b,:"00236/"
-1"[down]loading seeds data set";
.util.download[seeds.b;;"";""] seeds.f;
seeds.XY:("FFFFFFFH";"\t") 0: ssr[;"\t\t";"\t"] each read0 `$seeds.f
seeds.X:-1_seeds.XY
seeds.y:first seeds.Y:-1#seeds.XY
seeds.c:`area`perimeter`compactness`length`width`asymmetry`groove`variety
seeds.t:`variety xcols flip seeds.c!seeds.XY

