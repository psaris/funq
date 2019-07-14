/ sense and sensibility
sands.f:"161.txt"
sands.b:"http://www.gutenberg.org/files/161/"
-1"[down]loading sense and sensibility text";
.util.download[sands.b;;"";""] sands.f;
sands.txt:read0 `$sands.f
sands.chapters:"\n\n\n\nCHAPTER " vs "\n" sv  36_-373_sands.txt
sands.s:{first[x ss"\n\n"]_x} each 1_ sands.chapters
