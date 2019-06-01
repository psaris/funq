/ sense and sensibility
sands.f:"pg161.txt"
sands.b:"http://www.gutenberg.org/cache/epub/161/"
-1"[down]loading sense and sensibility text";
.util.download[sands.b;;"";""] sands.f;
sands.txt:.util.rbom read0 `$sands.f
sands.chapters:"\n\n\n\nCHAPTER " vs "\n" sv  36_-373_sands.txt
sands.s:{first[x ss"\n\n"]_x} each 1_ sands.chapters