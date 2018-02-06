\c 20 100
\l funq.q

/ redefine plot (to drop space)
plt:.util.plot[30;15;.util.c10]

-1"to demonstrate kmeans, we first generate clusters of data";
-1"we will arbitrarily choose 3 clusters and define k=3";
k:3

-1"we then generate k centroids,";
show C:"f"$k?/:2#20
-1"and scatter points around the centroids with normally distributed errors";
X:raze each C+.util.bm(2;k)#100?/:(2*k)#1f
show plt X

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
-1"the random partition method can be done by hand";
.ml.kmeans[X] over group count[X 0]?k
-1"the k-means++ method is used if the argument is a positive integer";
.ml.kmeans[X] over k
-1"the forgy method is used if the argument is a negate integer";
.ml.kmeans[X] over neg k
-1"we can plot the data and overlay the centroids found using kmeans++";
show plt .ml.append[0f;X],' .ml.append[1f].ml.kmeans[X] over k

-1"kmedians uses the lloyd algorithm, but uses the *manhattan distince*";
-1"also known as the taxicab metric to assign points to clusters";
-1"in addition, it uses the median instead of mean to compute the centroid";
-1"this forces the resulting centroid to have values picked from the data";
-1"it does not, however, force the centroid to be an actual point in the data";
-1"the centroid can be (x1;y2;z3), and not necessarily (x3;y3;z3)";
-1"we can see the progress by using scan instead of over";
show .ml.kmedians[X] scan k

-1"we can apply kmeans to the classic machine learning iris data";
f:("iris.data";"bezdekIris.data") 1
b:"http://archive.ics.uci.edu/ml/machine-learning-databases/iris/"
-1"we first [down]load the iris dataset";
.util.download[b;;"";::] f;
-1"and then extract the data into a matrix of data (with 4 dimensions)";
I:value 4#flip iris:150#flip `slength`swidth`plength`pwidth`species!("FFFFS";",") 0: `$f
-1"we can see how the data set clusters in the 4th dimension";
show plt I 3

-1"we iteratively call kmeans until convergence";
C:.ml.kmeans[I] over 3
-1"and can show which group each data point was assigned to.";
show g:.ml.cgroup[.ml.edist;I;C] / classify
-1"what percentage of the data did we classify correctly?";
avg iris.species=distinct[iris.species] .ml.ugrp g / accuracy
-1"what does the confusion matrix look like?";
show .util.totals[`TOTAL] .ml.cm[iris.species;distinct[iris.species] .ml.ugrp g]

-1"we can also plot the total distortion from using a different number of centroids";
/ plot errors with increasing number of centroids
show plt (.ml.distortion .ml.ecdist[I] .ml.kmeans[I]@) each neg 1+til 10
