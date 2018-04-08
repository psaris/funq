\c 20 100
\l funq.q
\l iris.q
\

d:`train`test!floor[.75*count iris.t] cut 0N?iris.t
-1 .ml.ptree[0] tree:.ml.ct[1;0W;::] `species xcols d`train;
`:tree.dot 0: .ml.pgraph tree
avg d.test.species=p:tree .ml.dtc/: d`test

/ clustering

/ redefine plot (to drop space)
plt:.util.plot[30;15;.util.c10]

/ cosine similarity (distance)
flip C:.ml.lloyd[.ml.cosdist;avg;iris.X]/[-3] /find 3 centroids
show g:.ml.cgroup[.ml.cosdist;iris.X;C]       / classify
avg iris.y=distinct[iris.y] .ml.ugrp g / accuracy

/ hierarchical (agglomerative) clustering analysis (HCA)
l:.ml.linkage[.ml.edist;.ml.ward] iris.X / perform clustering
t:.ml.tree flip 2#l                 / build dendrogram
plt 10#reverse l 2                  / determine optimal number of clusters
g:2 1 0!(raze/) each 2 .ml.slice/ t / cut into 3 clusters
avg iris.y=distinct[iris.y] .ml.ugrp g

/ k nearest neighbors

/ pick classification that occurs most frequently
/ from 3 closest points trained on 100 observations
nn:.ml.knn[.ml.edist;3;iris.y i;iris.X@\:i]'[flip iris.X (_')/i:desc -100?count iris.X 0]
avg nn=iris.y _/i

/ markov clustering
/ https://www.cs.ucsb.edu/~xyan/classes/CS595D-2009winter/MCL_Presentation2.pdf

/ example from mcl man page
/ http://micans.org/mcl/man/mcl.html
t:flip `k1`k2`v!"ssf"$\:()
t,:`cat`hat,0.2
t,:`hat`bat,0.16
t,:`bat`cat,1.0
t,:`bat`bit,0.125
t,:`bit`fit,0.25
t,:`fit`hit,0.5
t,:`hit`bit,0.16

/ take max of bidirectional links, enumerate keys
k:()
m:.ml.inflate[1;0f] .ml.addloop m|:flip m:.ml.full enlist[2#count k],exec (`k?k1;`k?k2;v) from t
(`hat`bat`cat;`bit`fit`hit)~(get`k!) each .ml.interpret .ml.mcl[2;1.5;0f] over m

/ cluster the iris data
sm:.5<.ml.gaussk[iris.X;.5] each flip iris.X / similarity matrix based on gaussian kernel
.ml.interpret .ml.mcl[2;1.5;10] over .ml.inflate[1;0f] sm
/ are there 4 species: http://www.siam.org/students/siuro/vol4/S01075.pdf

/ https://en.wikipedia.org/wiki/Naive_Bayes_classifier
X:(6 5.92 5.58 5.92 5 5.5 5.42 5.75;
 180 190 170 165 100 150 130 150f;
 12 11 12 10 6 8 7 9f)
y:`male`male`male`male`female`female`female`female / classes
Xt:(6 7f;130 190f;8 12f)                           / test data
flip clf:.ml.fitnb[.ml.gaussml;1f;X;y]             / build classifier
flip d:.ml.densitynb[.ml.gauss;clf] Xt             / compute densities
flip .ml.probabilitynb d        / convert densities to probabilities
`female`male~.ml.predictnb d    / make classification predictions
`female`male~.ml.lpredictnb .ml.densitynb[.ml.gaussll;clf] Xt / use log likelihood

/ iris
clf:.ml.fitnb[.ml.gaussml;1f;iris.X;iris.y] / build classifier
d:.ml.densitynb[.ml.gauss;clf] iris.X             / compute densities
flip .ml.probabilitynb d        / convert densities to probabilities
.96f~avg iris.y=.ml.predictnb d / how good is classification
.96f~avg iris.y=.ml.lpredictnb .ml.densitynb[.ml.gaussll;clf] iris.X / use log likelihood

/ inf2b-learn-note07-2up.pdf
X:(2 0 0 1 5 0 0 1 0 0 0;       / goal
 0 0 1 0 0 0 3 1 4 0 0;         / tutor
 0 8 0 0 0 1 2 0 1 0 1;         / variance
 0 0 1 8 0 1 0 2 0 0 0;         / speed
 1 3 0 0 1 0 0 0 0 0 7;         / drink
 1 1 3 8 0 0 0 0 1 0 0;         / defence
 1 0 5 0 1 6 1 1 0 0 1;         / performance
 1 0 0 1 9 1 0 2 0 0 0)         / field
Xt:flip(8 0 0 1 7 1 0 1;0 1 3 0 3 0 1 0)
y:(6#`sport),5#`informatics
/ bernoulli
flip clf:.ml.fitnb[.ml.binml[1];1f;0<X;y] / build classifier
flip d:.ml.densitynb[.ml.binla[1];clf] Xt / compute densities
`sport`informatics~.ml.predictnb d        / make classification prediction

/ bernoulli - add one smoothing
flip clf:.ml.fitnb[.ml.binml[2];1f;1+0<X;y]
`sport`informatics~.ml.predictnb .ml.densitynb[.ml.binla[2];clf] Xt
`sport`informatics~.ml.lpredictnb .ml.densitynb[.ml.binll[2];clf] Xt / use log likelihood

/ multinomial - add one smoothing
flip clf:.ml.fitnb[.ml.multiml[1];1f;X;y]
`sport`informatics~.ml.predictnb .ml.densitynb[.ml.multila;clf] Xt
`sport`informatics~.ml.lpredictnb .ml.densitynb[.ml.multill;clf] Xt / use log likelihood

/ https://www.youtube.com/watch?v=km2LoOpdB3A
X:(2 2 1 1; / chinese
 1 0 0 0;   / beijing
 0 1 0 0;   / shanghai
 0 0 1 0;   / macao
 0 0 0 1;   / tokyo
 0 0 0 1)   / japan
y:`c`c`c`j
Xt:flip enlist 3 0 0 0 1 1

/ multinomial - add one smoothing
flip clf:.ml.fitnb[.ml.multiml[1];1f;X;y]
flip d:.ml.densitynb[.ml.multila;clf] Xt
flip .ml.probabilitynb d
(1#`c)~.ml.predictnb d

/2 .ml.em[.ml.multila;.ml.multiml[1];X]/  2

/ tf idf

f:"stop-word-list.txt"
b:"http://xpo6.com/wp-content/uploads/2015/01/"
.util.download[b;;"";::] f
sw:enlist[""],read0 `$":",f

/ the bible
/ f:"pg10.txt"
/ b:"http://www.gutenberg.org/cache/epub/10/"
/ .util.download[b;;"";::] f
/ sf:{x where x like\: "1:1*"}  (last (3#"\n") vs) each (5#"\n") vs first (13#"\n") vs last (15#"\n") vs

/ pride and prejudice
f:"1342-0.txt"
b:"http://www.gutenberg.org/files/1342/"
.util.download[b;;"";::] f
sf:(last (3#"\n") vs) each -2_3_ (4#"\n") vs / define split function

/ convert utf-8 octal escapes
s:sf ssr[;"\342\200[\234\235]";"\""] ssr[;"\342\200[\231\230]";"'"] 3_"\n" sv lower read0 `$":",f
/ remove punctuation, plurals and -ing
s:(" " vs except[;"_().;,:?!*'\""] ssr[;"'s ";" "] ssr[;"ing ";" "] ssr[;"[-\n]";" "]@) each s

w:asc distinct[raze s] except sw / distinct word list (droping stop words)
m:((count each group@) each s)@\:w / matrix of word count per document (chapter)
/ vector space model (with different examples of tf-idf)
vsm:0f^.ml.tfidf[::;.ml.idf] m
vsm:0f^.ml.tfidf[.ml.lntf;.ml.idfm] m
vsm:0f^.ml.tfidf[.ml.dntf[.5];.ml.pidf] m
vsm@'idesc each vsm             / display values of top tf-idf
w 5#/:idesc each vsm            / display top words based on tf-idf
