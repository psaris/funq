/ moby dick
moby.f:"2701-0.txt"
moby.b:"http://www.gutenberg.org/files/2701/"
.util.download[moby.b;;"";""] moby.f;
moby.txt:.util.rbom read0 `$moby.f
moby.s:1_"CHAPTER " vs "\n" sv 848_-373_ moby.txt
