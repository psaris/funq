/ pride and prejudice
pandp.f:"1342-0.txt"
pandp.b:"http://www.gutenberg.org/files/1342/"
-1"[down]loading pride and prejudice text";
.util.download[pandp.b;;"";""] pandp.f;
pandp.txt:(ssr[;"      ";""] .util.cleanstr::) each read0 `$pandp.f
pandp.chapters:1_"\nChapter " vs "\n" sv  166_-373_ pandp.txt
pandp.s:{2_first[x ss"\n\n"]_x} each pandp.chapters
