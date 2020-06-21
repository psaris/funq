/ the bible
bible.f:"10.txt"
bible.b:"http://www.gutenberg.org/files/10/"
-1"[down]loading bible text";
.ut.download[bible.b;;"";""] bible.f;
bible.txt:read0 `$bible.f
bible.s:1_"\n1:1 " vs "\n" sv 39_-373_ bible.txt
