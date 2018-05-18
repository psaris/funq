pendigits.f:("pendigits.tra";"pendigits.tes")
pendigits.b:"http://archive.ics.uci.edu/ml/machine-learning-databases/pendigits/"
-1"download the pendigits training and test dataset";
.util.download[pendigits.b;;"";""] each pendigits.f;
-1"loading the training data";
pendigits.y:last pendigits.X:(17#"x";",") 0: `$pendigits.f 0
pendigits.X:-1_pendigits.X

-1"loading the test data";
pendigits.yt:last pendigits.Xt:(17#"x";",") 0: `$pendigits.f 1
pendigits.Xt:-1_pendigits.Xt


