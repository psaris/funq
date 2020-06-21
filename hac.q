\c 40 100
\l funq.q
\l iris.q
\l seeds.q
\l uef.q

/ hierarchical agglomerative clustering (HAC)
-1"normalize seed data set features";
X:.ml.zscore seeds.X
-1"build dissimilarity matrix";
D:.ml.f2nd[.ml.edist X] X
-1"generate hierarchical clustering linkage stats";
L:.ml.link[`.ml.lw.ward] D
-1"generate cluster indices";
I:.ml.clust[L] 1+til 10
-1"plot elbow curve (k vs ssw)";
show .ut.plt .ml.ssw[X] peach I
-1"plot elbow curve (k vs % of variance explained)";
show .ut.plt (.ml.ssb[X] peach I)%.ml.sse[X]
-1"link into 3 clusters";
I:.ml.clust[L] 3
-1"confirm accuracy";
g:(.ml.mode each seeds.y I)!I
.ut.assert[0.9] .ut.rnd[.01] avg seeds.y=.ut.ugrp g

-1"we can also check for maximum silhouette";
-1"plot silhouette curve (k vs silhouette)";
I:.ml.clust[L] 1+til 10
show .ut.plt (avg raze .ml.silhouette[.ml.edist;X]::) peach I


-1"normalize iris data set features";
X:.ml.zscore iris.X
-1"build dissimilarity matrix";
D:.ml.f2nd[.ml.edist X] X
-1"generate hierarchical clustering linkage stats";
L:.ml.link[`.ml.lw.median] D
-1"generate cluster indices";
I:.ml.clust[L] 1+til 10
-1"plot elbow curve (k vs ssw)";
show .ut.plt .ml.ssw[X] peach I
-1"plot elbow curve (k vs % of variance explained)";
show .ut.plt (.ml.ssb[X] peach I)%.ml.sse[X]

-1"link into 3 clusters";
I:.ml.clust[L] 3
-1"confirm accuracy";
g:(.ml.mode each iris.y I)!I
.ut.assert[.97] .ut.rnd[.01] avg iris.y=.ut.ugrp g
-1"generate clusters indices";
I:.ml.clust[L] 1+til 10
-1"plot silhouette curve (k vs silhouette)";
show .ut.plt (avg raze .ml.silhouette[.ml.edist;X]::) peach I

-1"let's apply the analysis to one of the uef reference cluster datasets";
X:uef.d32
show .ut.plot[39;20;.ut.c10;sum] X
-1"using pedist2 makes calculating the dissimilarity matrix much faster";
D:sqrt .ml.pedist2[X;X]
-1"generate hierarchical clustering linkage stats with ward metric";
L:.ml.link[`.ml.lw.ward] D
-1"generate cluster indices";
I:.ml.clust[L] ks:1+til 19
-1"plot elbow curve (k vs ssw)";
show .ut.plt .ml.ssw[X] peach I
-1"plot elbow curve (k vs % of variance explained)";
show .ut.plt (.ml.ssb[X] peach I)%.ml.sse[X]
-1"plot silhouette curve (k vs silhouette)";
show .ut.plt s:(avg raze .ml.silhouette[.ml.edist;X]::) peach I
.ut.assert[16] ks i:.ml.imax s
-1"plot the clustered data";
show .ut.plot[39;20;.ut.c68;.ml.mode] X[0 1],enlist .ut.ugrp I i
