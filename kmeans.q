\c 20 100
\l funq.q

/ redefine plot (to drop space)

-1"to demonstrate kmeans, we first generate clusters of data";
-1"we will arbitrarily choose 3 clusters and define k=3";
k:3

-1"we then generate k centroids,";
show C:"f"$k?/:2#20
-1"and scatter points around the centroids with normally distributed errors";
X:raze each C+.ml.bm(2;k)#100?/:(2*k)#1f
show .util.plt X

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
.ml.kmeans[X] over neg[k]?/:X
-1"the k-means++ method is supplied as an alternate initialization method";
.ml.kmeans[X] over last k .ml.kmeanspp[X]/ ()
-1"the random partition method can also be done by hand";
.ml.kmeans[X] over (avg'') X@\:value group count[X 0]?k
-1"we can plot the data and overlay the centroids found using kmeans++";
show .util.plt .ml.append[0N;X],' .ml.append[1] .ml.kmeans[X] over neg[k]?/:X

-1"kmedians uses the lloyd algorithm, but uses the *manhattan distance*";
-1"also known as the taxicab metric to assign points to clusters";
-1"in addition, it uses the median instead of mean to compute the centroid";
-1"this forces the resulting centroid to have values picked from the data";
-1"it does not, however, force the centroid to be an actual point in the data";
-1"the centroid can be (x1;y2;z3), and not necessarily (x3;y3;z3)";
-1"we can see the progress by using scan instead of over";
show .ml.kmedians[X] scan neg[k]?/:X

-1"we can apply kmeans to the classic machine learning iris data";
\l iris.q
`X`y`t set' iris`X`y`t;
-1"we can see how the data set clusters the petal width";
show .util.plt (t.pwidth;t.plength;{distinct[x]?x} t.species)

-1"we iteratively call kmeans until convergence";
C:.ml.kmeans[X] over last 3 .ml.kmeanspp[X]/ ()
-1"and can show which group each data point was assigned to";
show m:.ml.mode each y i:value .ml.cgroup[.ml.edist2;X;C] / classify
-1"what percentage of the data did we classify correctly?";
avg y=p:.ml.ugrp m!i            / accuracy
-1"what does the confusion matrix look like?";
show .util.totals[`TOTAL] .ml.cm[y;p]

/ plot errors with increasing number of clusters
-1"we can also plot the total distortion from using a different number of clusters";
show .util.plt {[X;k].ml.distortion X@\:.ml.cgroup[.ml.edist2;X] .ml.kmeans[X] over last k .ml.kmeanspp[X]/ ()}[X] each 1+til 10
