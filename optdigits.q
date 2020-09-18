optdigits.f:("optdigits.tra";"optdigits.tes")
optdigits.b:"http://archive.ics.uci.edu/ml/machine-learning-databases/"
optdigits.b,:"optdigits/"
-1"[down]loading optdigits data set";
.ut.download[optdigits.b;;"";""] each optdigits.f;
optdigits[`X`Y`Xt`Yt]:raze (64 cut (65#"H";",") 0: `$) each optdigits.f
optdigits[`y`yt]:optdigits[`Y`Yt][;0]
