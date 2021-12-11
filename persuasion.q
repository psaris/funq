/ persuasion
persuasion.f:"105.txt"
persuasion.b:"https://www.gutenberg.org/files/105/"
-1"[down]loading persuasion text";
.ut.download[persuasion.b;;"";""] persuasion.f;
persuasion.txt:read0 `$persuasion.f
persuasion.chapters:1_"Chapter" vs "\n" sv  44_-373_persuasion.txt
persuasion.s:{(3+first x ss"\n\n\n")_x} each persuasion.chapters
