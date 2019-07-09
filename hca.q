\c 40 100
\l funq.q
\l iris.q
\l seeds.q

/ hierarchical clustering analysis (HCA)
-1"normalize seed data set features";
X:.ml.zscore seeds.X
-1"build dissimilarity matrix";
D:.ml.f2nd[.ml.edist X] X
-1"generate hierarchical clustering linkage stats";
l:.ml.link[`.ml.lw.ward] D
-1"build a function that computes the total distortion over all clusters";
kdist:{[X;l;k]sum (.ml.distortion X@\:) each .ml.clust[k] l}
-1"plot elbow curve (k vs distortion)";
show .util.plt kdist[X;l] each 1+til 10
-1"link into 3 clusters";
c:.ml.clust[3] l
-1"confirm accuracy";
g:(.ml.mode each seeds.y c)!c
.util.assert[0.9] .util.rnd[.01] avg seeds.y=.ml.ugrp g

-1"normalize iris data set features";
X:.ml.zscore iris.X
-1"build dissimilarity matrix";
D:.ml.f2nd[.ml.edist X] X
-1"generate hierarchical clustering linkage stats";
l:.ml.link[`.ml.lw.median] D
-1"plot elbow curve (k vs distortion)";
show .util.plt kdist[X;l] each 1+til 10
-1"link into 3 clusters";
c:.ml.clust[3] l
-1"confirm accuracy";
g:(.ml.mode each iris.y c)!c
.util.assert[.97] .util.rnd[.01] avg iris.y=.ml.ugrp g
