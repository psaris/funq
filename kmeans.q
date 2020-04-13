\c 40 100
\l funq.q
\l iris.q
\l uef.q

/ redefine plot (to drop space)

-1"to demonstrate kmeans, we first generate clusters of data";
-1"we will arbitrarily choose 3 clusters and define k=3";
k:3

-1"we then generate k centroids,";
show C:"f"$k?/:2#20
-1"and scatter points around the centroids with normally distributed errors";
X:raze each C+.ml.bm(2;k)#100?/:(2*k)#1f
show .util.plot[19;10;.util.c10;sum] X

-1 .util.box["**"] (
 "kmeans is an implementation of lloyds algorithm,";
 "which alternates between assigning points to a cluster";
 "and updating the cluster's center.");
-1"kmeans uses the *euclidean distance* to assign points to clusters";
-1"and generates clusters using the *average* of the data points.";
-1"each call to kmeans performs a single iteration.";
-1"to find the centroids, we call kmeans iteratively until convergence.";
-1"there are two ways to initialze the algorithm:";
-1" 1. randomly pick k centroids (k-means++ and forgy method)";
-1" 2. assign points randomly to k centroids - random partition method";
-1"the forgy method is the simplest to implement";
.ml.kmeans[X] over .ml.forgy[k] X
-1"the k-means++ method is supplied as an alternate initialization method";
.ml.kmeans[X] over last k .ml.kmeanspp[X]// 2#()
-1"the random partition method can also be done by hand";
.ml.kmeans[X] over .ml.rpart[avg;k] X
-1"we can plot the data and overlay the centroids found using kmeans++";
show .util.plt .ml.append[0N;X],' .ml.append[1] .ml.kmeans[X] over .ml.forgy[k] X

-1"kmedians uses the lloyd algorithm, but uses the *manhattan distance*";
-1"also known as the taxicab metric to assign points to clusters";
-1"in addition, it uses the median instead of mean to compute the centroid";
-1"this forces the resulting centroid to have values picked from the data";
-1"it does not, however, force the centroid to be an actual point in the data";
-1"the centroid can be (x1;y2;z3), and not necessarily (x3;y3;z3)";
-1"(to use actual points from the data see k-medoids below)";
-1"we can see the progress by using scan instead of over";
show .ml.kmedians[X] scan .ml.forgy[k] X

-1"we can apply kmeans to the classic machine learning iris data";
`X`y`t set' iris`X`y`t;
-1"we can see how the data set clusters the petal width";
show .util.plt (t.pwidth;t.plength;{distinct[x]?x} t.species)

-1"we iteratively call kmeans until convergence";
C:.ml.kmeans[X] over last 3 .ml.kmeanspp[X]// 2#()
-1"and can show which group each data point was assigned to";
show m:.ml.mode each y I:.ml.cgroup[.ml.edist2;X;C] / classify
-1"what percentage of the data did we classify correctly?";
avg y=p:.util.ugrp m!I            / accuracy
-1"what does the confusion matrix look like?";
show .util.totals[`TOTAL] .util.cm[y;p]

/ plot errors with increasing number of clusters
-1"we can also plot the total ssw from using different values for k";
C:{[X;k].ml.kmeans[X] over last k .ml.kmeanspp[X]// 2#()}[X] each 1+til 10
show .util.plt .ml.distortion[X] peach C

-1"an alternative to k-means is the k-medoids algorithm";
-1"that finds actual data points at the center of each cluster";
-1"the algorithm is slower than k-means because it must computer";
-1"the full dissimilarity matrix for each cluster";
-1"the implementation is know as *partitioning around medoids*";
-1"and is implemented in .ml.pam";
-1"we can use any distance metric, but manhattan and euclidian";
-1"(not euclidian squared) are the most popular";
C:.ml.pam[.ml.edist][X] over X@\:3?count X
show .util.plt .ml.append[0N;X 1 2],'.ml.append[1] C 1 2

-1"let's apply the analyis to one of the uef reference cluster datasets";
X:uef.a1
show .util.plot[39;20;.util.c10;sum] X
-1"first we generate the centroids for a few values for k";
C:{[X;k].ml.kmeans[X] over last k .ml.kmeanspp[X]// 2#()}[X] peach ks:10+til 20
-1"then we cluster the data";
I:.ml.cgroup[.ml.edist2;X] peach C
-1"plot elbow curve (k vs ssw)";
show .util.plt .ml.ssw[X] peach I
-1"plot elbow curve (k vs % of variance explained)";
show .util.plt (.ml.ssb[X] peach I)%.ml.sse[X]
-1"plot silhouette curve (k vs silhouette)";
show .util.plt s:(avg raze .ml.silhouette[.ml.edist;X]::) peach I
ks i:.ml.imax s
-1"superimpose the centroids on the data";
show .util.plot[39;20;.util.c10;avg] .ml.append[0N;X],'.ml.append[1] C i
