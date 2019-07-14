/ persuasion
persuasion.f:"105.txt"
persuasion.b:"http://www.gutenberg.org/files/105/"
-1"[down]loading persuasion text";
.util.download[persuasion.b;;"";""] persuasion.f;
persuasion.txt:.util.rbom read0 `$persuasion.f
persuasion.chapters:1_"\n\n\n\nChapter " vs "\n" sv  44_-373_persuasion.txt
persuasion.s:{first[x ss"\n\n"]_x} each persuasion.chapters
