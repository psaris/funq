\l linear.q
\l ut.q
.linear.set_print_string_function `
.ut.assert[230i] .linear.version
.ut.assert[s] .linear.write_problem prob:.linear.read_problem s:read0 `:liblinear/heart_scale
.ut.assert[::] .linear.check_parameter[prob] param:.linear.defparam[prob] .linear.param
.ut.assert[prob] .linear.prob_inout prob
m1:.linear.train[prob;param]
m2:.linear.load_model `:liblinear/heart_scale.model
do[1000;m:.linear.load_model `:liblinear/heart_scale.model]
m3:{.linear.save_model[`model] x;m:.linear.load_model[`model];hdel`:model;m} m
mp:1#`solver_type
.ut.assert[@[m;`param;{y#x};mp]] @[m;`param;{y#x};mp]
do[1000;param ~ b:.linear.param_inout param]
.ut.assert[m] .linear.model_inout m
do[1000;.linear.model_inout m]
.ut.assert[1b].75<avg prob.y=.linear.cross_validation[prob;param;2i]
.ut.assert[0 -1 0f] .linear.find_parameters[prob;param;2i;-0f;-0f]
.ut.assert[0i] .linear.check_probability_model m
.ut.assert[.linear.predict[m;prob.x]] .linear.predict[m] each prob.x
.ut.assert[.linear.predict_values[m;prob.x]] flip .linear.predict_values[m] each prob.x
.ut.assert[.linear.predict_probability[m;prob.x]] flip .linear.predict_probability[m] each prob.x
