\c 20 100
\l funq.q
\l iris.q
\l weather.q
\l winequality.q

/ http://www.cise.ufl.edu/~ddd/cap6635/Fall-97/Short-papers/2.htm
/ http://www.saedsayad.com/decision_tree.htm
/ Paper_3-A_comparative_study_of_decision_tree_ID3_and_C4.5.pdf
/ https://www.jair.org/media/279/live-279-1538-jair.pdf
/ http://www.ams.org/publicoutreach/feature-column/fc-2014-12
/ http://support.sas.com/documentation/cdl/en/statug/68162/HTML/default/viewer.htm#statug_hpsplit_details06.htm

-1"load weather data, remove the day column and move Play to front";
show t:weather.t
-1"use the id3 algorithm to build a decision tree";
-1 .ml.ptree[0] tr:.ml.id3[();::] t;
`:tree.dot 0: .ml.pgraph tr
-1"the tree is built with triplets.";
-1"the first value is the decision feature,";
-1"and the second value is operator to use on the feature";
-1"and the third value is a dictionary representing the leaves";
-1"we can then use the (p)redict (d)ecission (t)ree function to classify our data";
avg t.Play=p:.ml.pdt[tr] each t / accuracy
-1"since the test and training data are the same, it is no surprise we have 100% accuracy";
-1".ml.pdt does not fail on missing features. it digs deeper into the tree";
.util.assert[.71428571428571431] avg t.Play=p:.ml.pdt[.ml.id3[();::] (1#`Outlook) _ t] each t
-1"id3 only handles discrete features.  c4.5 handles continues features";
-1".ml.q45 implements many of the features of c4.5 including:";
-1"* information gain normalized by split info";
-1"* handling of continuous features";
-1"* use of Minumum Description Length Principal (MDL) ";
-1"  to penalize features with many distinct continuous values";
-1"* pre-prunes branches that create branches with too few leaves";
-1"* post-prunes branches that overfit by given confidence value";
-1"we can test this feature by changing humidity into a continuous variable";
show s:@[t;`Humidity;:;85 90 78 96 80 70 65 95 70 80 70 90 75 80f]
-1"we can see how id3 creates a bushy tree";
-1 .ml.ptree[0] .ml.id3[();::] s;
-1"while q45 picks a single split value";

z:@[{.qml.nicdf x};.0125;2.241403];
-1 .ml.ptree[0] tr:.ml.prune[.ml.perr[z]] .ml.q45[();::] s;
.util.assert[1f] avg s.Play=p:.ml.pdt[tr] each s / accuracy
-1"we can still handle null values by using the remaining features";
.util.assert[`Yes] .ml.pdt[tr] d:`Outlook`Temperature`Humidity`Wind!(`Rain;`Hot;85f;`)
-1"we can even can handle nulls in the training data by propagating them down the tree";
s:update Temperature:` from s where Humidity=70f
-1 .ml.ptree[0] tr:.ml.q45[();::] s;
.util.assert[`No] .ml.pdt[tr] d
-1 "we can also use the Gini impurity instead of entropy (faster with similar behavior)";
-1 .ml.ptree[0] tr:.ml.dt[.ml.gr;.ml.ogr;.ml.wgini;();::] t;
d:`Outlook`Temperature`Humidity`Wind!(`Rain;`Hot;`High;`) / remove null
.util.assert[`No] .ml.pdt[tr] d
-1 "we can also create an aid tree when the target is numeric";
-1 .ml.ptree[0] tr:.ml.aid[(1#`minsl)!1#3;::] update "e"$`Yes=Play from t; / regression tree
.util.assert[.2] .ml.pdt[tr] d
-1 "we can also create a thaid tree for classification";
-1 .ml.ptree[0] tr:.ml.thaid[(1#`minsl)!1#3;::] t; / classification tree
.util.assert[`Yes] .ml.pdt[tr] d

-1 "we can now split the iris data into training and test batches (w/ stratification)";
w:`train`test!3 1
show d:.util.part[w;iris.t.species] iris.t
-1 "note that stratification can work on any type of list or table";
.util.part[w;;iris.t] count[iris.t]?5;
.util.part[w;select species from iris.t] iris.t;
-1 "next we confirm relative frequencies of species are the same";
.util.assert[1b] .ml.identical value count each group d.train.species
-1 "then create a classification tree";
-1 .ml.ptree[0] tr:.ml.ct[();::] `species xcols d`train;
-1 "testing the tree on the test set produces an accuracy of:";
avg d.test.species=p:tr .ml.pdt/: d`test
-1 "we can save the decision tree into graphviz compatible format";
`:tree.dot 0: .ml.pgraph tr;
-1 "using graphviz to convert the .dot file into a png";
@[system;"dot -Tpng -o tree.png tree.dot";0N!];

-1 "we can predict iris petal lengths with a regression tree";
-1 "first we need to one-hot encode the species";
t:"f"$.util.onehot iris.t
-1 "then split the data into training and test batches"
show d:.util.part[w;0N?] t
-1 "and generate a regression tree";
-1 .ml.ptree[0] tr:.ml.rt[();::]  `plength xcols d`train;
-1 "we now compute the root mean square error (rmse)";
.ml.rms d.test.plength-p:tr .ml.pdt/: d`test

-1 "using breiman algorithm, compute pruning alphas";
dtf:.ml.ct[();::]
ef:.ml.wmisc

/ http://mlwiki.org/index.php/Cost-Complexity_Pruning
t:([]z:`b`b`b`b`w`w`w`w`w`w`b`b`w`w`b`b)
t:t,'([]x:1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4)
t:t,'([]y:1 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4 )
-1 .ml.ptree[0] tr:dtf t;
.util.assert[0 0.125 0.125 0.25] first atr:flip .ml.dtmina[ef] scan (0f;tr)

-1 "we then pick the alpha (and therefore subtree) with cross validation";
b:sqrt (1_a,0w)*a:atr 0 / geometric mean
ts:.util.part[(k:10)#1;0N?] t
show e:avg each ts[;`z]=p:.ml.dtxv[dtf;ef;b;ts] peach til k
-1 .ml.ptree[0] atr[1] 0N!.ml.imax 0N!avg e;

-1 "returning to the iris data, we can grow and prune that too";
-1 .ml.ptree[0] tr:dtf iris.t;
.util.assert[0 .01 .02 .02 .04 .88 1f] 3*first atr:flip .ml.dtmina[ef] scan (0f;tr)
b:sqrt (1_a,0w)*a:atr 0 / geometric mean
ts:.util.part[(k:10)#1;0N?]iris.t
show e:avg each ts[;`species]=p:.ml.dtxv[dtf;ef;b;ts] peach til k
-1 .ml.ptree[0] atr[1] 0N!.ml.imax 0N!avg e;

-1 "or even grow and prune a regression tree with wine quality data";
d:.util.part[`train`test!1 1;0N?] winequality.red.t
dtf:.ml.rt[();::]
ef:.ml.wmse
-1 "the fully grown tree has more than 200 leaves!";
.util.assert[1b] 200<0N!count .ml.leaves tr:dtf d`train
-1 "we can improve this by performing k-fold cross validation";
-1 "first we find the list of critical alphas";
atr:flip .ml.dtmina[ef] scan (0f;tr)
b:sqrt (1_a,0w)*a:atr 0 / geometric mean
ts:.util.part[(k:5)#1;0N?]d`train
-1 "then we compute the accuracy of each of these alphas with kfxv";
show e:avg each e*e:ts[;`quality]-p:(.ml.dtxv[dtf;ef;b;ts]0N!) peach til k
-1 "finally, we pick the tree whose alpha had the min error";
-1 .ml.ptree[0] btr:atr[1] 0N!.ml.imin 0N!avg e;
-1 "the pruned tree has less than 25 leaves";
.util.assert[1b] 25>0N!count .ml.leaves btr
-1 "and an rms less than .73";
.util.assert[1b] .73>0N!.ml.rms d.test.quality - btr .ml.pdt/: d`test
