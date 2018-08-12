/ pride and prejudice
pandp.f:"1342-0.txt"
pandp.b:"http://www.gutenberg.org/files/1342/"
.util.download[pandp.b;;"";""] pandp.f
/ split function
pandp.sf:(last (3#"\n") vs) each -2_3_ (4#"\n") vs
pandp.txt:.util.rbom read0 `$pandp.f
