\c 40 100
\l funq.q
\l iris.q

/ hierarchical (agglomerative) clustering analysis (HCA)
l:.ml.linkage[.ml.edist;.ml.ward] iris.X / perform clustering
t:.ml.tree flip 2#l                      / build dendrogram
show .util.plt 10#reverse l 2   / determine optimal number of clusters
g:(.ml.mode each iris.y g)!g:(raze/) each 2 .ml.slice/ t / cut into 3 clusters
avg iris.y=.ml.ugrp g

