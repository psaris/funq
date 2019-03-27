\c 20 100
\l funq.q
\l stopwords.q
\l emma.q
\l pandp.q
\l sands.q
\l mansfield.q
\l northanger.q
t:flip `text`class!(emma.s;`E)
t,:flip `text`class!(pandp.s;`P)
t,:flip `text`class!(sands.s;`S)
t,:flip `text`class!(mansfield.s;`M)
t,:flip `text`class!(northanger.s;`N)

-1"cleaning and stripping text";
t:update (.util.stripstr lower .util.cleanstr@) peach text from t
-1"tokenizng and stemming text";
t:update (.porter.stem each " " vs) peach text from t
-1"partitioning text between training and test";
d:`train`test!.ml.part[3 1] t
c:d . `train`text
y:d . `train`class
-1"generating vocabulary and term document matrix";
sw:.porter.stem peach stopwords.xpo6
X:0f^.ml.tfidf[.ml.lntf;.ml.idf] .ml.tdm[c] v:asc distinct[raze c] except sw
-1 "fitting multinomial naive bayes classifier";
pT:.ml.fitnb[.ml.wmultimle[1];(::);flip X;y]
-1"confirming accuracy";
ct:d . `test`text
yt:d . `test`class
Xt:0f^.ml.tfidf[.ml.lntf;.ml.idf] .ml.tdm[ct] v
avg yt=p:.ml.clfnb[1b;.ml.multill;pT] flip Xt
show select[>N] from ([]word:v)!flip last pT
