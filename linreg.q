\c 20 100
\l funq.q

plt:.util.plot[30;15;.util.c10]

-1"generating 2 sets of independent normal random variables";
/ NOTE: matrix variables are uppercase
-1 .util.box["**"](
 "suppress the desire to flip matrices";
 "matlab/octave/r all store data in columns";
 "the following matrix *is* a two column matrix in q");
show X:(.ml.bm 10000?) each 1 1f

/ perhaps q needs the ability to tag matrices so they can be displayed
/ (not stored) flipped

-1"plotting uncorrelations x,y";
show plt[sum] X

-1"using $ to generate correlated x and y";
rho:.8                          / correlation
X[1]:(rho;sqrt 1f-rho*rho)$X

-1"plotting correlations x,y";
show plt[sum] X

-1 .util.box["**"] (
 "mmu is usually used for matrix multiplication";
 "$ is usually used for vector dot product";
 "but they can be used interchangeably");

Y:-1#X
X:1#X

-1"linear algebra often involves an operation such as";
-1"Y times X transpose or Y*X'. Matlab and Octave can parse";
-1"this syntax and perform the multiplication/transpose";
-1"by a change of indexation rather than physically moving the data";
-1"to get this same effect in q, we can change the";
-1"operation from 'Y mmu flip X' to 'X$/:Y'";
-1"timing with the flip";
\ts:100 Y mmu flip X
-1"and without";
\ts:100 X$/:Y

-1"fitting a line *without* intercept";
show THETA:Y lsq 1#X

-1"to fit intercept, prepend a vector of 1s";
show .ml.prepend[1f] X

-1"fitting a line with intercept";
show THETA:Y lsq .ml.prepend[1f] 1#X

-1"plotting data with fitted line";
show plt[avg] .ml.append[0N;X,Y],'.ml.append[1]X,.ml.plin[X] THETA;

-1"fitting with normal equations (fast but not numerically stable)";
.ml.normeq[Y;.ml.prepend[1f] X]

if[2<count key `.qml;
 -1"qml uses QR decomposition for a more numerically stable fit";
 0N!.qml.mlsqx[`flip;.ml.prepend[1f] X;Y];
 ];

-1"its nice to have closed form solution, but what if we don't?";
-1"we can use gradient descent as well";
alpha:.1                        / learning rate
THETA:enlist theta:2#0f         / initial values
-1"by passing a learning rate and function to compute the gradient";
-1".ml.gd will take one step in the steepest direction";
mf:.ml.gd[alpha;.ml.lingrad[();Y;X]]
mf THETA

-1"we can then use q's iteration controls";
-1"to run a fixed number of iterations";
2 mf/ THETA
-1"iterate until the cost is within a tolerance";
cf:.ml.lincost[();X;Y]
(.4<0N!cf::) mf/ THETA
-1"or even until convergence";
mf over THETA
-1"to iterate until cost reductions taper off, we need our own function";
-1"we can change the logging behavior by changing the file handle";
-1"no logging";
first .ml.iter[0N;.01;cf;mf] THETA
-1"in-place progress";
first .ml.iter[1;.01;cf;mf] THETA
-1"new-line progress";
first .ml.iter[-1;.01;cf;mf] THETA
-1"by passing an integer for the limit, we can run n iterations";
first .ml.iter[-1;20;cf;mf] THETA

l:1000f / l2 regularization factor
-1"we can reduce over-fitting by adding l2 regularization";
gf:.ml.lingrad[.ml.l2[l];Y;X]
first .ml.iter[1;.01;cf;.ml.gd[alpha;gf]] THETA

-1"we can also use the fmincg minimizer to obtain optimal theta values";
cgf:.ml.lincostgrad[.ml.l2[l];Y;X]
first .fmincg.fmincg[1000;cgf;theta]

-1"linear regression with l2 regularization has a closed-form solution";
-1"called ridge regression";
-1"in this example, we fit an un-regularized intercept";
.ml.ridge[0f,count[X]#l;Y;.ml.prepend[1f]X]

-1"let's check that we've implemented the gradient calculations correctly";
cf:.ml.lincost[.ml.l2[l];Y;X]enlist::
gf:first .ml.lingrad[.ml.l2[l];Y;X]enlist::
.util.assert . .util.rnd[1e-6] .ml.checkgrad[1e-4;cf;gf;theta]
cgf:.ml.lincostgrad[.ml.l2[l];Y;X]
cf:first cgf::
gf:last cgf::
.util.assert . .util.rnd[1e-6] .ml.checkgrad[1e-4;cf;gf;theta]
