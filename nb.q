\l funq.q
\l iris.q

/ https://en.wikipedia.org/wiki/Naive_Bayes_classifier
X:(6 5.92 5.58 5.92 5 5.5 5.42 5.75; / height (feet)
 180 190 170 165 100 150 130 150f;   / weight (lbs)
 12 11 12 10 6 8 7 9f)               / foot size (inches)
y:`male`male`male`male`female`female`female`female / classes
Xt:(6 7f;130 190f;8 12f)                           / test data
-1"assuming gaussian distribution";
-1"analyzing mock dataset";
-1"building classifier";
show clf:.ml.fitnb[.ml.wgaussmle/:;::;X;y] / build classifier
-1"confirming accuracy";
.util.assert[`female`male] .ml.clfnb[0b;.ml.gaussl;clf] Xt / make classification predictions
.util.assert[`female`male] .ml.clfnb[1b;.ml.gaussll;clf] Xt / use log likelihood

/ iris
-1"analyzing iris data set";
-1"building classifier";
clf:.ml.fitnb[.ml.wgaussmle/:;::;iris.X;iris.y] / build classifier
-1"confirming accuracy";
.util.assert[.96f] avg iris.y=.ml.clfnb[0b;.ml.gaussl;clf] iris.X / how good is classification
.util.assert[.96f] avg iris.y=.ml.clfnb[1b;.ml.gaussll;clf] iris.X / how good is classification

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
-1"assuming bernoulli distribution";
-1"analyzing mock dataset";
/ bernoulli
-1"building classifier";
show clf:.ml.fitnb[.ml.wbinmle[1;0]/:;::;0<X;y] / build classifier
-1"confirming accuracy";
.util.assert[`sport`informatics] .ml.clfnb[0b;.ml.binla[1];clf] Xt  / make classification prediction
.util.assert[`sport`informatics] .ml.clfnb[1b;.ml.binll[1];clf] Xt  / make classification prediction

/ bernoulli - add one smoothing
-1"testing bernoulli add one smoothing";
show clf:.ml.fitnb[.ml.wbinmle[2;0]/:;::;1+0<X;y]
.util.assert[`sport`informatics] .ml.clfnb[0b;.ml.binla[2];clf] Xt
.util.assert[`sport`informatics] .ml.clfnb[1b;.ml.binll[2];clf] Xt / use log likelihood

/ multinomial - add one smoothing
-1"testing multinomial add one smoothing";
show clf:.ml.fitnb[.ml.wmultimle[1];::;X;y]
.util.assert[`sport`informatics] .ml.clfnb[0b;.ml.multila;clf] Xt
.util.assert[`sport`informatics] .ml.clfnb[1b;.ml.multill;clf] Xt / use log likelihood

/ https://www.youtube.com/watch?v=km2LoOpdB3A
X:(2 2 1 1; / chinese
 1 0 0 0;   / beijing
 0 1 0 0;   / shanghai
 0 0 1 0;   / macao
 0 0 0 1;   / tokyo
 0 0 0 1)   / japan

y:`c`c`c`j
-1"analyzing another mock dataset"
-1"testing multinomial add one smoothing";
Xt:flip enlist 3 0 0 0 1 1

/ multinomial - add one smoothing
-1"building classifier";
show flip clf:.ml.fitnb[.ml.wmultimle[1];::;X;y]
-1"confirming accuracy";
.util.assert[1#`c] .ml.clfnb[0b;.ml.multila;clf] Xt
.util.assert[1#`c] .ml.clfnb[1b;.ml.multill;clf] Xt

