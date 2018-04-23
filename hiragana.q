\c 100 300
\l funq.q
\l etl9b.q

/ use a neural network to learn 71 hiragana characters
/ inspired by the presentation given by mark lefevre
/ http://www.slideshare.net/MarkLefevreCQF/machine-learning-in-qkdb-teaching-kdb-to-read-japanese-67119780

/ dataset specification
/ http://etlcdb.db.aist.go.jp/?page_id=1711


-1"setting the prng seed";
system "S ",string "i"$.z.T

-1"view 4 random drawings of the same character";
plt:.util.plot[64;32;.util.c10] .util.hmap flip 64 cut
-1 value (,') over plt each flip etl9b.X[;rand[count etl9b.h]+count[distinct etl9b.y]*til 4];

-1"generate neural network topology with one hidden layer";
n:0N!{(x;(x+y) div 2;y)}[count etl9b.X;count etl9b.h]
YMAT:.ml.diag[last[n]#1f]@\:"i"$etl9b.y

-1"initialize theta with random weights";
theta:2 raze/ .ml.ninit'[-1_n;1_n];
l:1                           / lambda (l2 regularization coefficient)
-1"run mini-batch stochastic gradient descent",$[l;" with l2 regularization";""];
mf:{first .fmincg.fmincg[10;.ml.nncostgrad[l;n;etl9b.X[;y];YMAT[;y]];x]}
theta:1 .ml.sgd[mf;0N?;100;etl9b.X]/ theta

-1"checking accuracy of parameters";
avg etl9b.y=p:.ml.predictonevsall[etl9b.X] .ml.nncut[n] theta

w:where not etl9b.y=p
-1"view a few confused characters";
-1 value (,') over plt each flip etl9b.X[;value ([]p;etl9b.y) rw:rand w];
-1 value (,') over plt each flip etl9b.X[;value ([]p;etl9b.y) rw:rand w];

-1"view the confusion matrix";
show .util.totals[`TOTAL] .ml.cm[etl9b.y;"j"$p]