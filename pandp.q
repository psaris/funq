/ pride and prejudice
pandp.f:"1342-0.txt"
pandp.b:p"http://www.gutenberg.org/files/1342/"
.util.download[pandp.b;;"";""] pandp.f;
pandp.txt:.util.rbom read0 `$pandp.f
pandp.chapters:1_"\nChapter " vs "\n" sv  36_-373_ pandp.txt
pandp.s:{first[x ss"\n\n"]_x} each pandp.chapters
