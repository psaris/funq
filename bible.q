/ the bible
bible.f:"pg10.txt"
bible.b:"http://www.gutenberg.org/cache/epub/10/"
.util.download[bible.b;;"";""] bible.f;
bible.sf:{x where x like\: "1:1*"}  (last (3#"\n") vs) each (5#"\n") vs first (13#"\n") vs last (15#"\n") vs
bible.txt:.util.rbom read0 `$bible.f
