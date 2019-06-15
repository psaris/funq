\c 40 100
\l funq.q
\l iris.q
\l seeds.q

/ hierarchical clustering analysis (HCA)
-1"build dissimilarity matrix for seed data set";
dm:.ml.f2nd[.ml.edist seeds.X] seeds.X;
-1"generate heirarchical clustering linkage stats";
l:.ml.hclust[`.ml.lw.ward] dm
show .util.plt 10#reverse l 2
-1"build clusters";
c:(raze/) each .ml.link[3] flip 2#l
-1"cut into 3 clusters";
g:(.ml.mode each seeds.y c)!c
-1"confirm accuracy";
.util.assert[0.89] .util.rnd[.01] avg seeds.y=.ml.ugrp g


-1"build dissimilarity matrix for iris data set";
dm:.ml.f2nd[.ml.edist iris.X] iris.X;
l:.ml.hclust[`.ml.lw.median] dm
show .util.plt 10#reverse l 2
-1"build clusters";
c:(raze/) each .ml.link[3] flip 2#l
-1"cut into 3 clusters";
g:(.ml.mode each iris.y c)!c
-1"confirm accuracy";
.util.assert[.9] avg iris.y=.ml.ugrp g

