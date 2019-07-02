\c 40 100
\l funq.q
\l iris.q

/ cosine similarity (distance)
X:.ml.normalize iris.X
flip C:.ml.skmeans[X] over -3?/:X      / spherical k-means
show m:.ml.mode each iris.y i:value .ml.cgroup[.ml.cosdist;X;C] / classify
avg iris.y=.ml.ugrp m!i / accuracy
