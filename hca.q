\c 40 100
\l funq.q
\l iris.q
\l seeds.q

/ hierarchical clustering analysis (HCA)
-1"build dissimilarity matrix for seed data set";
D:.ml.f2nd[.ml.edist seeds.X] seeds.X;
-1"generate heirarchical clustering linkage stats";
l:.ml.link[`.ml.lw.ward] D
-1"plot cluster distances";
show .util.plt 10#reverse l 2
-1"link into 3 clusters";
c:.ml.clust[3] flip 2#l
-1"confirm accuracy";
g:(.ml.mode each seeds.y c)!c
.util.assert[0.89] .util.rnd[.01] avg seeds.y=.ml.ugrp g

-1"build dissimilarity matrix for iris data set";
D:.ml.f2nd[.ml.edist iris.X] iris.X;
-1"generate heirarchical clustering linkage stats";
l:.ml.link[`.ml.lw.median] D
-1"plot cluster distances";
show .util.plt 10#reverse l 2
-1"link into 3 clusters";
c:.ml.clust[3] flip 2#l
-1"confirm accuracy";
g:(.ml.mode each iris.y c)!c
.util.assert[.9] avg iris.y=.ml.ugrp g

