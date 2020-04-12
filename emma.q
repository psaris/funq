/ emma
emma.f:"158.txt"
emma.b:"http://www.gutenberg.org/files/158/"
-1"[down]loading emma text";
.util.download[emma.b;;"";""] emma.f;
emma.txt:{x where not x like "VOLUME*"} read0 `$emma.f
emma.chapters:1_"CHAPTER" vs "\n" sv 39_-373_emma.txt
emma.s:{(3+first x ss"\n\n\n")_x} each emma.chapters
