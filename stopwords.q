stopwords.f:"stop-word-list.txt"
stopwords.b:"http://xpo6.com/wp-content/uploads/2015/01/"
-1"[down]loading xpo6 stop words";
.util.download[stopwords.b;;"";""] stopwords.f;
stopwords.xpo6:enlist[""],read0 `$":",stopwords.f

stopwords.f:"stop.txt"
stopwords.b:"http://snowball.tartarus.org/algorithms/english/"
-1"[down]loading snowball stop words";
.util.download[stopwords.b;;"";""] stopwords.f;
stopwords.snowball:asc distinct trim {(x?"|")#x} each read0 `$":",stopwords.f
