\l svm.q
\l ut.q
.svm.set_print_string_function `
.ut.assert[323i] .svm.version
.ut.assert[s] .svm.write_problem prob:.svm.read_problem s:read0 `:libsvm/heart_scale
.ut.assert[::] .svm.check_parameter[prob] param:.svm.defparam[prob] .svm.param
.ut.assert[prob] .svm.prob_inout prob
m1:.svm.train[prob;param]
m2:.svm.load_model `:libsvm/heart_scale.model
do[1000;m:.svm.load_model `:libsvm/heart_scale.model]
m3:{.svm.save_model[`model] x;m:.svm.load_model[`model];hdel`:model;m} m
mp:`svm_type`kernel_type`gamma
.ut.assert[@[m;`param;{y#x};mp]] @[m;`param;{y#x};mp]
do[1000;param ~ .svm.param_inout param]
.ut.assert[m] .svm.model_inout m
do[1000;.svm.model_inout m]
.ut.assert[1b] .8<avg prob.y=.svm.cross_validation[prob;param;2i]
.ut.assert[0i].svm.check_probability_model m
.ut.assert[.svm.predict[m;prob.x]] .svm.predict[m] each prob.x
.ut.assert[.svm.predict_values[m;prob.x]] flip .svm.predict_values[m] each prob.x
.ut.assert[.svm.predict_probability[m;prob.x]] flip .svm.predict_probability[m] each prob.x
