/ use a neural network to learn 71 hiragana characters
/ inspired by the presentation given by mark lefevre
/ http://www.slideshare.net/MarkLefevreCQF/machine-learning-in-qkdb-teaching-kdb-to-read-japanese-67119780

/ dataset specification
/ http://etlcdb.db.aist.go.jp/?page_id=1711

\c 100 300
\l funq.q

-1"[down]loading handwritten kanji dataset";
f:"ETL9B"                                      / zip file base
b:"http://etlcdb.db.aist.go.jp/etlcdb/data/"   / base url
.util.download[b;;".zip";system 0N!"unzip ",] f; / download data

-1"loading etl9b ('binalized' dataset)";
x:.util.etl9b read1 `:ETL9B/ETL9B_1

-1"extracting the X matrix and y vector";
h:0x24,/:"x"$0x21+0x01*til 83 / hiragana
/ h:0x25,/:"x"$0x21+0x01*til 83 / katakana (missing)
y:h?y w:where (y:flip x 1 2) in h
X:"f"$flip (raze 0b vs/:) each (1_x 4) w / extract 0 1 from bytes

-1"setting the prng seed";
system "S ",string "i"$.z.T

-1"view 4 random drawings of the same character";
plt:.plot.plot[39;20;.plot.c10] .plot.hmap flip 64 cut
show value (,') over plt each flip X[;rand[count h]+count[distinct y]*til 4]

-1"generate neural network topology with one hidden layer";
n:0N!{(x;"j"$.5*x+y;y)}[count X;count h]
YMAT:.ml.diag[last[n]#1f]@\:"i"$y

-1"initialize theta with random weights";
theta:2 raze/ .ml.ninit'[-1_n;1_n];

l:1                             / lambda (regularization coeficient)
-1"run batch gradient descent",$[l;" with regularization";""];
theta: first .fmincg.fmincg[50;.ml.nncost[l;n;X;YMAT];theta]

-1"checking accuracy of parametes";
avg y=p:.ml.predictonevsall[X] .ml.nncut[n] theta

w:where not y=p
-1"view a few confused characters";
show value (,') over plt each flip X[;value ([]p;y) rw:rand w]
show value (,') over plt each flip X[;value ([]p;y) rw:rand w]

-1"view the confusion matrix";
show .util.totals[`TOTAL] .ml.cm[y;"j"$p]