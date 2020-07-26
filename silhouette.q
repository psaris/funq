\c 20 77
\l funq.q
\l zoo.q
\l iris.q

-1"computing the silhouette demonstrates cluster quality";
-1"by generating a statistic that varies between -1 and 1";
-1"where 1 indicates a point is very close to all the items";
-1"within its own cluster and very far from all the items";
-1"in the next-best cluster while -1 indicates the reverse";
-1"a negative value indicates a point is closer to the next-best cluster";
-1"";
-1"we now apply silhouette analysis to the zoo data set";
df:`.ml.edist
-1"using distance metric: ", string df;
t:(2#/:zoo.t),'([]silhouette:.ml.silhouette[df;zoo.X;zoo.y])
-1"sorting by avg silhouette within each cluster";
-1"then by actual data point silhouette value";
-1"provides good intuition on cluster quality";
show select[>([](avg;silhouette) fby typ;silhouette)] from t
-1"assert average silhouette";
.ut.assert[.3] .ut.rnd[.1] exec avg silhouette from t
-1"we see that mammals platypus, seal, dolphin and porpoise";
-1"as well as all the reptiles are better classified";
-1"as another type";
show 75_select[>([](avg;silhouette) fby typ;silhouette)] from t

-1"we can run the same analysis on the iris data set";
t:iris.t,'([]silhouette:.ml.silhouette[df;iris.X;iris.y])
-1"we see that iris-setosa is the best cluster";
-1"and iris-versicolor and iris-virginica are worse";
show select avg silhouette by species from t
-1"assert average silhouette";
.ut.assert[.5] .ut.rnd[.1] exec avg silhouette from t
