pandp.f:"1342-0.txt"
pandp.b:"https://www.gutenberg.org/files/1342/"
-1"[down]loading pride and prejudice text";
.ut.download[pandp.b;;"";""] pandp.f;
pandp.txt:read0 `$pandp.f
pandp.chapters:1_"\nChapter " vs "\n" sv  35_-373_ pandp.txt
pandp.s:{first[x ss"\n\n"]_x} each pandp.chapters
