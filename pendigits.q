pendigits.f:("pendigits.tra";"pendigits.tes")
pendigits.b:"http://archive.ics.uci.edu/ml/machine-learning-databases/pendigits/"
-1"download the pendigits training and test data set";
.util.download[pendigits.b;;"";""] each pendigits.f;
pendigits.y:last pendigits.X:(17#"h";",") 0: `$pendigits.f 0
pendigits.X:-1_pendigits.X

pendigits.yt:last pendigits.Xt:(17#"h";",") 0: `$pendigits.f 1
pendigits.Xt:-1_pendigits.Xt


