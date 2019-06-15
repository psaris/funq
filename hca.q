\c 40 100
\l funq.q
\l iris.q

/ hierarchical clustering analysis (HCA)
-1"build dissimilarity matrix";
dm:.ml.f2nd[.ml.edist iris.X] iris.X;
-1"generate heirarchical clustering linkage stats";
l:.ml.hclust[`.ml.lw.ward] dm
show .util.plt 10#reverse l 2 

l:.ml.hclust[`.ml.lw.median] dm
-1"build dendrogram";
tr:.ml.tree flip 2#l
-1"cut into 3 clusters";
g:(.ml.mode each iris.y g)!g:(raze/) each 2 .ml.slice/ tr;
-1"confirm accuracy";
.util.assert[.9] avg iris.y=.ml.ugrp g

