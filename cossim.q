\c 40 100
\l funq.q
\l iris.q

/ cosine similarity (distance)
X:.ml.normalize iris.X
flip C:.ml.skmeans[X] over .ml.forgy[3] X / spherical k-means
show m:.ml.mode each iris.y I:.ml.cgroup[.ml.cosdist;X;C] / classify
avg iris.y=.util.ugrp m!I / accuracy
