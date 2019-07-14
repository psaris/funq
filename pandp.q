/ pride and prejudice
pandp.f:"1342.txt"
pandp.b:"http://www.gutenberg.org/files/1342/"
-1"[down]loading pride and prejudice text";
.util.download[pandp.b;;"";""] pandp.f;
pandp.txt:read0 `$pandp.f
pandp.chapters:1_"\nChapter " vs "\n" sv  35_-373_ pandp.txt
pandp.s:{first[x ss"\n\n"]_x} each pandp.chapters
