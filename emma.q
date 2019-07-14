/ emma
emma.f:"158.txt"
emma.b:"http://www.gutenberg.org/files/158/"
-1"[down]loading emma text";
.util.download[emma.b;;"";""] emma.f;
emma.txt:read0 `$emma.f
emma.chapters:"\n\n\n\nCHAPTER " vs "\n" sv  35_-373_emma.txt
emma.s:{first[x ss"\n\n"]_x} each {x where 15<count each x}emma.chapters
