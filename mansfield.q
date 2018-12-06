/ mansfield park
mansfield.f:"141-0.txt"
mansfield.b:"http://www.gutenberg.org/files/141/"
.util.download[mansfield.b;;"";""] mansfield.f;
mansfield.txt:.util.rbom read0 `$mansfield.f
mansfield.chapters:1_"\n\n\n\nCHAPTER " vs "\n" sv  36_-373_mansfield.txt
mansfield.s:{first[x ss"\n\n"]_x} each mansfield.chapters

