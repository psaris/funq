berkstan.f:"web-BerkStan.txt"
berkstan.b:"http://snap.stanford.edu/data/"
-1"[down]loading berkstan network graph";
.ut.download[berkstan.b;;".gz";.ut.gunzip] berkstan.f;
berkstan.l:("II";"\t") 0:  4_read0 `$berkstan.f
