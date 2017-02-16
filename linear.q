.linear.dll:`linear^.linear.dll^:`; / optional override

.linear,:(.linear.dll 2: (`qml_linear_lib;1))`
.linear,:`L2R_LR`L2R_L2LOSS_SVC_DUAL`L2R_L2LOSS_SVC!"i"$til 3
.linear,:`L2R_L1LOSS_SVC_DUAL`MCSVM_CS`L1R_L2LOSS_SVC!3i+"i"$til 3
.linear,:`L1R_LR`L2R_LR_DUAL!6i+"i"$til 2
.linear,:`L2R_L2LOSS_SVR`L2R_L2LOSS_SVR_DUAL`L2R_L1LOSS_SVR_DUAL!11i+"i"$til 3

\d .linear

param:(!) . flip (
 (`solver_type;L2R_L2LOSS_SVC_DUAL);
 (`eps;0f);                     / uses defaults
 (`C;1f);
 (`weight_label;::);
 (`weight;::);
 (`p;.1);
 (`init_sol;::));

defeps:(!) . flip (
 (L2R_LR;0.01);
 (L2R_L2LOSS_SVC;0.01);
 (L2R_L2LOSS_SVR;0.001);
 (L2R_L2LOSS_SVC_DUAL;0.1);
 (L2R_L1LOSS_SVC_DUAL;0.1);
 (MCSVM_CS;0.1);
 (L2R_LR_DUAL;0.1);
 (L1R_L2LOSS_SVC;0.01);
 (L1R_LR;0.01);
 (L2R_L1LOSS_SVR_DUAL;0.1);
 (L2R_L2LOSS_SVR_DUAL;0.1))

defparam:{[prob;param]
 if[0f>=param`eps;param[`eps]:defeps param`solver_type];
 param}

read_problem:{[s]
 i:s?\:" ";
 y:i#'s;
 x:{(!/)"I: "0:x _y}'[1+i;s];
 if[3.5>.z.K;x:("i"$key x)!value x];
 `bias`x`y!-1f,"F"$(x;y)}
write_problem:{
 s:(("+";"")0>x`y),'string x`y;
 s:s,'" ",/:{" " sv ":" sv' string flip(key x;value x)} each x`x;
 s:s,\:" ";
 s}
