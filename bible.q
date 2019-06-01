/ the bible
bible.f:"pg10.txt"
bible.b:"http://www.gutenberg.org/cache/epub/10/"
-1"[down]loading bible text";
.util.download[bible.b;;"";""] bible.f;
bible.txt:.util.rbom read0 `$bible.f
bible.s:1_"\n1:1 " vs "\n" sv 39_-373_ bible.txt
