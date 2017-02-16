.svm.dll:`svm^.svm.dll^:`; / optional override

.svm,:(.svm.dll 2: (`qml_svm_lib;1))`
.svm,:`C_SVC`NU_SVC`ONE_CLASS`EPSILON_SVR`NU_SVR!"i"$til 5
.svm,:`LINEAR`POLY`RBF`SIGMOID`PRECOMPUTED!"i"$til 5

\d .svm

param:(!) . flip (
 (`svm_type;C_SVC);
 (`kernel_type;RBF);
 (`degree;3i);
 (`gamma;-1f);                  / use defaults
 (`coef0;0f);
 (`cache_size;100f);
 (`eps;.001);
 (`C;1f);
 (`weight_label;::);
 (`weight;::);
 (`nu;.5);
 (`p;.1);
 (`shrinking;1i);
 (`probability;0i))

defparam:{[prob;param]
 if[0f>param`gamma;param[`gamma]:1f%max(last key@)each prob`x];
 param}

read_problem:{[s]
 i:s?\:" ";
 y:i#'s;
 x:{(!/)"I: "0:x _y}'[1+i;s];
 if[3.5>.z.K;x:("i"$key x)!value x];
 `x`y!"F"$(x;y)}
write_problem:{
 s:(("+";"")0>x`y),'string x`y;
 s:s,'" ",/:{" " sv ":" sv' string flip(key x;value x)} each x`x;
 s:s,\:" ";
 s}
