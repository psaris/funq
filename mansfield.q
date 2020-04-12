/ mansfield park
mansfield.f:"141.txt"
mansfield.b:"http://www.gutenberg.org/files/141/"
-1"[down]loading mansfield park text";
.util.download[mansfield.b;;"";""] mansfield.f;
mansfield.txt:read0 `$mansfield.f
mansfield.chapters:1_"CHAPTER" vs "\n" sv 35_-373_mansfield.txt
mansfield.s:{(2+first x ss"\n\n")_x} each mansfield.chapters

