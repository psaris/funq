/ sense and sensibility
sands.f:"161.txt"
sands.b:"http://www.gutenberg.org/files/161/"
-1"[down]loading sense and sensibility text";
.util.download[sands.b;;"";""] sands.f;
sands.txt:read0 `$sands.f
sands.chapters:1_"CHAPTER" vs "\n" sv  43_-373_sands.txt
sands.s:{(3+first x ss"\n\n\n")_x} each sands.chapters
