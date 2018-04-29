\l funq.q
\l stopwords.q
\l pandp.q
\l bible.q

-1 "converting utf-8 octal escapes";
s:bible.sf ssr[;"\342\200[\234\235]";"\""] ssr[;"\342\200[\231\230]";"'"] 3_"\n" sv lower bible.txt
-1 "removing punctuation, plurals and -ing";
s:(" " vs except[;"_().;,:?!*'\""] ssr[;"'s ";" "] ssr[;"ing ";" "] ssr[;"[-\n]";" "]@) each s

-1 "computing distinct word list (droping stop words)";
w:asc distinct[raze s] except stopwords.sw
-1 "building a matrix of word count per document (chapter)";
m:((count each group@) each s)@\:w
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
show w 5#/:idesc each vsm
