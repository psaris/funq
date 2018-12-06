/ emma
emma.f:"158-0.txt"
emma.b:"http://www.gutenberg.org/files/158/"
.util.download[emma.b;;"";""] emma.f;
emma.txt:.util.rbom read0 `$emma.f
emma.chapters:"\n\n\n\nCHAPTER " vs "\n" sv  36_-373_emma.txt
emma.s:{first[x ss"\n\n"]_x} each {x where 15<count each x}emma.chapters
