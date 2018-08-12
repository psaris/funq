stopwords.f:"stop-word-list.txt"
stopwords.b:"http://xpo6.com/wp-content/uploads/2015/01/"
.util.download[stopwords.b;;"";""] stopwords.f
stopwords.sw:enlist[""],read0 `$":",stopwords.f
