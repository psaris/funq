\l funq.q

f:("iris.data";"bezdekIris.data") 1
b:"http://archive.ics.uci.edu/ml/machine-learning-databases/iris/"
-1"we first [down]load the iris dataset";
.util.download[b;;"";::] f;
-1"and then extract the data into a matrix of data (with 4 dimensions)";
I:value 4#flip iris:150#flip `slength`swidth`plength`pwidth`species!("FFFFS";",") 0: `$f
-1"enumerate species so we can use the integer value for svm";
iris:update `species?species from iris
-1"svm parameter x is a sparse matrix: - list of dictionaries";
prob:`x`y!(0 1 2 3i!/:flip I;"f"$"i"$iris`species)
-1"define and check svm parameters";
.svm.check_parameter[prob] param:.svm.defparam[prob] .svm.param
-1"build model by training svm on full dataset";
m:.svm.train[prob;param]
-1"cross validate";
.svm.cross_validation[prob;param;2i];
-1"how well did we learn";
avg prob.y=p:.svm.predict[m] each prob.x
-1"lets view the confusion matrix";
show .util.totals[`TOTAL] .ml.cm[`species!"i"$prob.y] `species!"i"$p