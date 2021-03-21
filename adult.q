adult.f:("adult.data";"adult.test")
adult.b:"http://archive.ics.uci.edu/ml/machine-learning-databases/"
adult.b,:"adult/"
-1"[down]loading adult data set";
.ut.download[adult.b;;"";""] each adult.f;
adult.c:`age`workclass`fnlwgt`education`educationnum`maritalstatus
adult.c,:`occupation`relationship`race`sex`capitalgain`capitalloss
adult.c,:`hoursperweek`nativecountry`gt50
adult[`t`tt]:(-1_flip adult.c!("HSISHSSSSSIIISS";",") 0:) each `$adult.f
adult.tt _:0                    / drop comment
{update like[;">50K*"] each gt50 from x} each `adult.t`adult.tt;
adult[`X`Y`Xt`Yt]:raze (0 14 cut value flip@) each adult`t`tt
adult[`y`yt]:first each adult`Y`Yt

