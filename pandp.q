/ pride and prejudice
pandp.f:"1342-0.txt"
pandp.b:"http://www.gutenberg.org/files/1342/"
.util.download[pandp.b;;"";""] pandp.f;
pandp.txt:.util.rbom read0 `$pandp.f
pandp.s:1_"\nChapter " vs "\n" sv  36_-373_ pandp.txt
