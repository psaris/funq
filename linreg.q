\c 20 100
\l funq.q

plt:.util.plot[30;15;.util.c10]

-1"generating 2 sets of independant normal random variables";
/ NOTE: matrix variables are uppercase
-1 .util.box["**"](
 "suppress the desire to flip matrices";
 "matlab/octave/r all store data in columns";
 "the following matrix *is* a two column matrix in q");
show X:(.ml.bm 10000?) each 1 1f

/ perhaps q needs the ability to tag matrices so they can be displayed
/ (not stored) flipped

-1"plotting uncorrelations x,y";
show plt X

-1"using $ to generate correlated x and y";
rho:.8                          / correlation
X[0]:(rho;sqrt 1f-rho*rho)$X

-1"plotting correlations x,y";
show plt X

-1 .util.box["**"] (
 "mmu is usually used for matrix multiplication";
 "$ is usually used for vector dot product";
 "but they can be used interchangably");

Y:-1#X
X:1#X

-1"linear algebra often involves an operation such as";
-1"Y times X transpse or Y*X'. Matlab and Octave can parse";
-1"this syntax and perform the multiplication/transpose";
-1"by a change of indexation rather than physcially moving the data";
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
show plt .ml.append[0;X,Y],'.ml.append[1]X,.ml.predict[X] THETA;

-1"fitting with normal equations (fast but not numerically stable)";
.ml.normeq[Y;.ml.prepend[1f] X]

if[2<count key `.qml;
 -1"qml uses QR decomposition for a more numerically stable fit";
 0N!.qml.mlsqx[`flip;.ml.prepend[1f] X;Y];
 ];

-1"its nice to have closed form solution, but what if we don't?";
-1"we can use gradient descent as well";
alpha:.1                        / learning rate
THETA:1 2#0f                    / initial values
-1"by passing a learning rate and function to compute the gradient";
-1".ml.gd will take one step in the steepest direction";
.ml.gd[alpha;.ml.lingrad[X;Y]] THETA

-1"we can then use q's iteration controls";
-1"to run a fixed number of iterations";
2 .ml.gd[alpha;.ml.lingrad[X;Y]]/ THETA
-1"or iterate until the cost is within a tolerance";
(.4<.ml.lincost[X;Y]@) .ml.gd[alpha;.ml.lingrad[X;Y]]/ THETA
-1"or even until convergence";
.ml.gd[alpha;.ml.lingrad[X;Y]] over THETA
