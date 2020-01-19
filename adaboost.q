\c 20 100
\l funq.q
\l pima.q
\l weather.q

/ https://cseweb.ucsd.edu/~yfreund/papers/adaboost.ps

-1 .ml.ptree[0] tree:.ml.q45[();::] pima.t;
avg pima.t.class=.ml.dtc[tree] each pima.t / accuracy
-1 "a stump is a single branch tree";
stump:.ml.q45[(1#`maxd)!1#1]
-1 .ml.ptree[0] stump[::] pima.t;
t:update -1 1 class from pima.t
r:20 (.ml.adaboost[stump;.ml.dtc;pima.t]last::)\(0f;2 1#1;n#1f%n:count pima.t)
avg pima.t.class=signum sum r[;0] * signum r[;1] .ml.dtc/:\: pima.t

show t:weather.t
t:update -1 1 `Yes=Play from weather.t
r:20 (.ml.adaboost[stump;.ml.dtc;t]last::)\(0f;2 1#1;n#1f%n:count t)
avg t.Play=signum sum r[;0] * signum r[;1] .ml.dtc/:\: t
