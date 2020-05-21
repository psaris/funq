\l funq.q
\l iris.q

stdout:1@
.svm.set_print_string_function`stdout
-1"enumerate species so we can use the integer value for svm";
y:`species?iris.y
-1"svm parameter x is a sparse matrix: - list of dictionaries";
prob:`x`y!(0 1 2 3i!/:flip iris.X;"f"$"i"$y)
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
