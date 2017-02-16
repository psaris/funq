\c 20 100
\l funq.q

\

f:("iris.data";"bezdekIris.data") 1
b:"http://archive.ics.uci.edu/ml/machine-learning-databases/iris/"
-1"we first [down]load the iris dataset";
.util.download[b;;"";::] f;
-1"and then extract the data into a matrix of data (with 4 dimensions)";
I:value 4#flip iris:150#flip `slength`swidth`plength`pwidth`species!("FFFFS";",") 0: `$f

/ clustering

/ redefine plot (to drop space)
plt:.plot.plot[28;15;1_.plot.c10]

/ cosine similarity (distance)
flip C:.ml.lloyd[.ml.cosdist;avg;I]/[-3] /find 3 centroids
show g:.ml.cgroup[.ml.cosdist;I;C]       / classify
avg iris.species=distinct[iris.species] .ml.ugrp g / accuracy

/ hierarchical (agglomerative) clustering analysis (HCA)
l:.ml.linkage[.ml.edist;.ml.ward] I / perform clustering
t:.ml.tree flip 2#l                 / build dendrogram
plt 10#reverse l 2                  / determine optimal number of clusters
g:2 1 0!(raze/) each 2 .ml.slice/ t / cut into 3 clusters
avg iris.species=distinct[iris.species] .ml.ugrp g


/ expectation maximization (EM)

/ binomial example
/ http://www.nature.com/nbt/journal/v26/n8/full/nbt1406.html
n:10
x:sum each (1000110101b;1111011111b;1011111011b;1010001100b;0111011101b)
theta: .6 .5                    / initial coefficients
lf:.ml.binla[n]                 / likelihood function
mf:.ml.binml[n]                 / parameter maximization function
/ pass phi as 1 because coins are picked with equal probability
.ml.em[lf;mf;x] (1;theta)
.ml.em[lf;mf;x] over (1;theta)  / call until convergence
.ml.em[lf;mf;x] over 2          / let .ml.em initialize parameters
/ which flips came from which theta? pick maximum log likelkhood
.ml.imax each flip .ml.binll[n;;x] each last .ml.em[lf;mf;x] over (1;theta)

/ gaussian mixtures
/ http://mccormickml.com/2014/08/04/gaussian-mixture-models-tutorial-and-matlab-code/
/ 1d gauss
mu0:10 20 30                    / distribution's mu
s20:s0*s0:1 3 2                 / distribution's variance
m0:100 200 150                  / number of points per distribution
X:raze X0:mu0+s0*(.util.bm ?[;1f]@) each m0 / build dataset
plt raze each (X0;0f*X0),'(X0;.ml.gauss'[mu0;s20;X0]) / plot 1d data and guassian curves
k:count mu0
phi:k#1f%k;                     / guess that distributions occur with equal frequency
mu:neg[k]?X;                    / pick k random points as centers
s2:k#var X;                     / use the whole datasets variance
lf:.ml.gauss                    / likelihood function
mf:.ml.gaussml                  / maximum function
.ml.em[lf;mf;X] over pt:(phi;mu;s2) / returns best guess for (phi;mu;s)
.ml.em[lf;mf;X] over k

/ 2d gauss
mu0:(10 20;-10 -20;0 0)
S20:((30 -20;-20 30);(20 0; 0 50);(10 2; 5 10)) / SIGMA (covariance matrix)
m0:1000 2000 1000

R0:.qml.mchol each S20          / sqrt(SIGMA)
X:(,') over X0:mu0+R0$'(.util.bm (?).)''[flip each flip (m0;3 2#1f)]
plt X

k:count mu0
phi:k#1f%k                      / equal probability
mu:flip X[;neg[k]?count X 0]    / pick k ransom points for mu
S:k#enlist X cov\:/: X          / full covariance matrix

lf:.ml.gaussmv
mf:.ml.gaussmlmv
.ml.em[lf;mf;X] over (phi;mu;S)
.ml.em[lf;mf;X] over k          / let .ml.em initialize parameters

/ lets try the iris data again for >2d

k:count distinct iris`species
phi:k#1f%k                      / equal prior probability
mu:flip I[;neg[k]?count I 0]    / random initialization
S:k#enlist I cov\:/: I          / sample covariance
lf:.ml.gaussmv
mf:.ml.gaussmlmv
.ml.em[lf;mf;I] over (phi;mu;S)
a:.ml.em[lf;mf;I] over k          / let .ml.em initialize parameters
/ how well did it cluster the data?
g:0 1 2!value group .ml.imax each flip lf[;;I]'[a[1];a[2]]
avg iris.species=distinct[iris.species] .ml.ugrp g

/ k nearest neighbors

/ pick classification that occurs most frequently
/ from 3 closest points trained on 100 observations
nn:.ml.knn[.ml.edist;3;iris.species i;I@\:i]'[flip I (_')/i:desc -100?count I 0]
avg nn=iris.species _/i

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
sm:.5<.ml.gaussk[I;.5] each flip I / similarity matrix based on gaussian kernel
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
clf:.ml.fitnb[.ml.gaussml;1f;I;iris.species] / build classifier
d:.ml.densitynb[.ml.gauss;clf] I             / compute densities
flip .ml.probabilitynb d        / convert densities to probabilities
.96f~avg iris.species=.ml.predictnb d / how good is classification
.96f~avg iris.species=.ml.lpredictnb .ml.densitynb[.ml.gaussll;clf] I / use log likelihood

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

/ sparse matrix
X:"f"$(100;100)#0 0 0 0 0 0 0 1
/ matrix -> sparse -> matrix == matrix
X~.ml.full S:.ml.sparse X
/ sparse matrix multiplication == mmu
(X$X)~.ml.full .ml.smm[S;S]
/ transposition works too
(X$flip X)~.ml.full .ml.smm[S;.ml.sflip S]

/ pagerank
/ http://www.cs.princeton.edu/~chazelle/courses/BIB/pagerank.htm
/ http://www.mathworks.com/help/matlab/examples/use-page-rank-algorithm-to-rank-websites.html
s:"aaabbcddd"
t:"bcddabcab"
S:(1 2#1+max raze 2#S),S:.ml.append[1f] distinct[s,t]?/:(s;t)
X:.ml.full S
s:1 1 2 2 3 3 3 4 5
t:2 5 3 4 4 5 6 1 1
S:(1 2#max s,t), .ml.append[1f] (s;t)-1
X:.ml.full S

/ pagerank matrix inversion
/ https://www.mathworks.com/moler/exm/chapters/pagerank.pdf
.ml.drank .ml.pageranki[.85;X]

/ https://en.wikipedia.org/wiki/PageRank
\ts:1000 .ml.drank .ml.pagerankr[.85;X] over r:n#1f%n:count X

/ https://en.wikipedia.org/wiki/Google_matrix
X:(01100000b;10001000b;01000001b;00100000b;00010001b;00011000b;00010100b;10010010b)
.ml.drank .ml.pageranki[.85;X]     / matrix inversion
.ml.drank .ml.pagerankr[.85;"f"$X] over r:n#1f%n:count X / function iteration
.ml.drank $[;.ml.google[.85;X]] over r:n#1f%n:count X    / non-sparse matrix iteration

s:1 2 3 3 3 4 4
t:2 1 1 3 5 3 5
S:(1 2#max s,t), .ml.append[1f] (s;t)-1
X:.ml.full S
.ml.drank .ml.pageranki[.85;X]
.ml.drank .ml.pagerankr[.85;"f"$X] over r:n#1f%n:count X
.ml.drank $[;.ml.google[.85;X]] over r:n#1f%n:count X

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
