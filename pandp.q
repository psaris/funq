/ pride and prejudice
pandp.f:"1342-0.txt"
pandp.b:"http://www.gutenberg.org/files/1342/"
-1"[down]loading pride and prejudice text";
.util.download[pandp.b;;"";""] pandp.f;
pandp.txt:read0 `$pandp.f
pandp.chapters:1_"Chapter" vs "\n" sv  6_'166_-373_ pandp.txt
pandp.s:{(2+first x ss"\n\n")_x} each .util.sr[.util.ua] peach pandp.chapters
