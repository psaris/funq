\c 40 100
\l funq.q
\l iris.q

/ cosine similarity (distance)
flip C:.ml.lloyd[.ml.cosdist;avg;iris.X]/[-3] /find 3 centroids
show g:.ml.cgroup[.ml.cosdist;iris.X;C]       / classify
avg iris.y=distinct[iris.y] .ml.ugrp g / accuracy
