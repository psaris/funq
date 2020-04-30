\l funq.q
\l stopwords.q
\l bible.q
\l moby.q
\l emma.q
\l pandp.q
\l sands.q
\l mansfield.q
\l northanger.q
\l persuasion.q

-1 "remove punctuation from text";
c:.util.sr[.util.pw] peach moby.s
-1 "tokenize and remove stop words";
c:(except[;stopwords.xpo6] " " vs ) peach lower c
-1 "user porter stemmer to stem each word";
c:(.porter.stem') peach c
-1 "building a term document matrix from corpus and vocabulary";
m:.ml.tdm[c] v:asc distinct raze c
-1 "building a vector space model (with different examples of tf-idf)";
-1 "vanilla tf-idf";
vsm:0f^.ml.tfidf[::;.ml.idf] m
-1 "log normalized term frequency, inverse document frequency max";
vsm:0f^.ml.tfidf[.ml.lntf;.ml.idfm] m
-1 "double normalized term frequency, probabilistic inverse document frequency";
vsm:0f^.ml.tfidf[.ml.dntf[.5];.ml.pidf] m
-1 "display values of top words based on tf-idf";
show vsm@'idesc each vsm
-1 "display top words based on tf-idf";
show v 5#/:idesc each vsm

vsm:0f^.ml.tfidf[::;.ml.idf] m
X:.ml.normalize vsm
C:.ml.skmeans[X] .ml.forgy[30] X

-1"using tfidf and nb to predict which jane austen book a chapter came from";

t:flip `text`class!(emma.s;`EM)        / emma
t,:flip `text`class!(pandp.s;`PP)      / pride and prejudice
t,:flip `text`class!(sands.s;`SS)      / sense and sensibility
t,:flip `text`class!(mansfield.s;`MP)  / mansfield park
t,:flip `text`class!(northanger.s;`NA) / northanger abbey
t,:flip `text`class!(persuasion.s;`PE) / persuasion

-1"remove punctuation from text";
t:update .util.sr[.util.pw] peach text from t
-1"tokenize and remove stop words";
t:update (except[;stopwords.xpo6] " " vs ) peach lower text from t
-1 "use porter stemmer to stem each word";
t:update (.porter.stem') peach text from t
-1"partitioning text between training and test";
d:.util.part[`train`test!3 1;0N?] t
c:d . `train`text
y:d . `train`class
-1"generating vocabulary and term document matrix";
X:0f^.ml.tfidf[.ml.lntf;.ml.idf] .ml.tdm[c] v:asc distinct raze c
-1 "fitting multinomial naive bayes classifier";
pT:.ml.fnb[.ml.wmultimle[1];(::);flip X;y]
-1"confirming accuracy";
ct:d . `test`text
yt:d . `test`class
Xt:0f^.ml.tfidf[.ml.lntf;.ml.idf] .ml.tdm[ct] v
avg yt=p:.ml.pnb[1b;.ml.multill;pT] flip Xt
show .util.rnd[1e-4] select[>PE] from ([]word:v)!flip last pT
