\c 40 100
\l funq.q
\l iris.q

/ hierarchical clustering analysis (HCA)
l:-4#.ml.lw[.ml.ward] over .ml.lwdm[.ml.edist] iris.X / generate linkage stats
t:.ml.tree flip 2#l             / build dendrogram
show .util.plt 10#reverse l 2   / determine optimal number of clusters
g:(.ml.mode each iris.y g)!g:(raze/) each 2 .ml.slice/ t / cut into 3 clusters
avg iris.y=.ml.ugrp g

