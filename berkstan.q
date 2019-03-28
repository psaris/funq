berkstan.f:"web-BerkStan.txt"
berkstan.b:"http://snap.stanford.edu/data/"
-1"[down]loading berkstan network graph";
.util.download[berkstan.b;;".gz";"gunzip -v"] berkstan.f;
berkstan.l:("II";"\t") 0:  4_read0 `$berkstan.f
