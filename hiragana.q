\c 100 300
\l funq.q
\l etl9b.q

/ use a neural network to learn 71 hiragana characters
/ inspired by the presentation given by mark lefevre
/ http://www.slideshare.net/MarkLefevreCQF/machine-learning-in-qkdb-teaching-kdb-to-read-japanese-67119780

/ dataset specification
/ http://etlcdb.db.aist.go.jp/?page_id=1711


-1"referencing etl9b data from global namespace";
`X`y`h set' etl9b`X`y`h
-1"shrinking training set";
X:500#'X;y:500#y;h:500#h;

-1"setting the prng seed";
system "S ",string "i"$.z.T

-1"view 4 random drawings of the same character";
plt:.util.plot[64;32;.util.c10;avg] .util.hmap flip 64 cut
-1 value (,') over plt each flip X[;rand[count h]+count[distinct y]*til 4];

-1"generate neural network topology with one hidden layer";
n:0N!{(x;(x+y) div 2;y)}[count X;count h]
Y:.ml.diag[last[n]#1f]@\:"i"$y

-1"initialize theta with random weights";
theta:2 raze/ .ml.glorotu'[1+-1_n;1_n];
l:1                           / lambda (l2 regularization coefficient)
-1"run mini-batch stochastic gradient descent",$[l;" with l2 regularization";""];
hgflf:`.ml.sigmoid`.ml.dsigmoid`.ml.sigmoid`.ml.logloss

mf:{first .fmincg.fmincg[5;.ml.nncostgrad[0;l;n;hgflf;X[;y];Y[;y]];x]}
theta:1 .ml.sgd[mf;0N?;100;X]/ theta

-1"checking accuracy of parameters";
avg y=p:.ml.predictonevsall[X] .ml.nncut[n] theta

w:where not y=p
-1"view a few confused characters";
-1 value (,') over plt each flip X[;value ([]p;y) rw:rand w];
-1 value (,') over plt each flip X[;value ([]p;y) rw:rand w];

-1"view the confusion matrix";
show .util.totals[`TOTAL] .ml.cm[y;"j"$p]
