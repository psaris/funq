\c 20 100
\l funq.q
\l onp.q

-1"bagging grows B decision trees with a random sampling (with replacement) of data";
m:.ml.bag[10;.ml.q45[2;0W;::]] 500?onp.t
avg onp.t.popular=.ml.mode each m .ml.dtc\:/: onp.t

-1"a random forest grows B decision trees with a random sampling of data and p features";
m:.ml.rfo[10;floor sqrt count cols onp.t;.ml.q45[2;0W;::]] 500?onp.t
avg onp.t.popular=.ml.mode each m .ml.dtc\:/: onp.t
