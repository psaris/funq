\l funq.q

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
