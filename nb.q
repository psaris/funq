\l funq.q
\l iris.q
\l stopwords.q
\l smsspam.q

/ https://en.wikipedia.org/wiki/Naive_Bayes_classifier
X:(6 5.92 5.58 5.92 5 5.5 5.42 5.75; / height (feet)
 180 190 170 165 100 150 130 150f;   / weight (lbs)
 12 11 12 10 6 8 7 9f)               / foot size (inches)
y:`male`male`male`male`female`female`female`female / classes
Xt:(6 7f;130 190f;8 12f)                           / test data
-1"assuming Gaussian distribution";
-1"analyzing mock dataset";
-1"building classifier";
show pT:.ml.fnb[.ml.wgaussmle/:;::;y;X] / build classifier
-1"confirming accuracy";
.ut.assert[`female`male] .ml.pnb[0b;.ml.gaussl;pT] Xt / make classification predictions
.ut.assert[`female`male] .ml.pnb[1b;.ml.gaussll;pT] Xt / use log likelihood

/ iris
-1"analyzing iris data set";
-1"building classifier";
pT:.ml.fnb[.ml.wgaussmle/:;::;iris.y;iris.X] / build classifier
-1"confirming accuracy";
.ut.assert[.96f] avg iris.y=.ml.pnb[0b;.ml.gaussl;pT] iris.X / how good is classification
.ut.assert[.96f] avg iris.y=.ml.pnb[1b;.ml.gaussll;pT] iris.X / how good is classification

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
-1"assuming Bernoulli distribution";
-1"analyzing mock dataset";
/ Bernoulli
-1"building classifier";
show pT:.ml.fnb[.ml.wbinmle[1;0]/:;::;y;0<X] / build classifier
-1"confirming accuracy";
.ut.assert[`sport`informatics] .ml.pnb[0b;.ml.binl[1];pT] Xt / make classification prediction
.ut.assert[`sport`informatics] .ml.pnb[1b;.ml.binll[1];pT] Xt / make classification prediction

/ Bernoulli - add one smoothing
-1"testing Bernoulli add one smoothing";
show pT:.ml.fnb[.ml.wbinmle[2;0]/:;::;y;1+0<X]
.ut.assert[`sport`informatics] .ml.pnb[0b;.ml.binl[2];pT] Xt
.ut.assert[`sport`informatics] .ml.pnb[1b;.ml.binll[2];pT] Xt / use log likelihood

/ multinomial - add one smoothing
-1"testing multinomial add one smoothing";
show pT:.ml.fnb[.ml.wmultimle[1];::;y;X]
.ut.assert[`sport`informatics] .ml.pnb[0b;.ml.multil;pT] Xt
.ut.assert[`sport`informatics] .ml.pnb[1b;.ml.multill;pT] Xt / use log likelihood

/ https://www.youtube.com/watch?v=km2LoOpdB3A
X:(2 2 1 1; / chinese
 1 0 0 0;   / beijing
 0 1 0 0;   / shanghai
 0 0 1 0;   / macao
 0 0 0 1;   / tokyo
 0 0 0 1)   / japan

y:`c`c`c`j
-1"analyzing another mock dataset";
-1"testing multinomial add one smoothing";
Xt:flip enlist 3 0 0 0 1 1

/ multinomial - add one smoothing
-1"building classifier";
show flip pT:.ml.fnb[.ml.wmultimle[1];::;y;X]
-1"confirming accuracy";
.ut.assert[1#`c] .ml.pnb[0b;.ml.multil;pT] Xt
.ut.assert[1#`c] .ml.pnb[1b;.ml.multill;pT] Xt

-1"modeling spam/ham classifier";
-1"remove unicode and punctuation characters from sms text";
t:update .ut.sr[.ut.ua,.ut.ha,.ut.pw] peach text from smsspam.t
-1"tokenizing and removing stop words from sms text";
t:update (except[;stopwords.xpo6] " " vs) peach lower text from t
-1"user porter stemmer to stem sms txt";
t:update (.porter.stem') peach text from t
-1"partitioning sms messages between training and test";
d:.ut.part[`train`test!3 1;0N?] t
c:d . `train`text
y:d . `train`class
-1"generating vocabulary and term document matrix";
X:.ml.tdm[c] v:asc distinct raze c
ct:d . `test`text
yt:d . `test`class
Xt:.ml.tdm[ct] v
-1 "fitting multinomial naive bayes classifier";
pT:.ml.fnb[.ml.wmultimle[1];::;y;flip X]
-1"confirming accuracy";
avg yt=p:.ml.pnb[0b;.ml.multil;pT] flip Xt
-1 "sorting model by strong spam signal";
show select[>spam] from ([]word:v)!flip last pT
-1 "sorting model by strong spam relative signal";
show select[>spam%ham] from ([]word:v)!flip last pT
