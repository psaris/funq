\c 20 100
\l funq.q
\l mnist.q
\l winequality.q

/ digit recognition
-1"referencing mnist data from global namespace";
`X`Xt`y`yt set' mnist`X`Xt`y`yt;
-1"shrinking training set";
X:1000#'X;y:1000#y;
-1"normalize data set";
X%:255f;Xt%:255f

-1"define a plot function (which includes the empty space character)";
plt:value .util.plot[28;14;.util.c10;avg] .util.hmap flip 28 cut
-1"visualize the data";
-1 (,'/) plt each X@\:/: -4?count X 0;

-1"we first generate a matrix of y values where each row only has a single 1 value";
-1"the location of which corresponds the the digit in the dataset";

show Y:.ml.diag[(1+max y)#1f]@\:y

-1"neural networks include multiple layers";
-1"where the first and last are visible, but all others are hidden";
-1"to cost and gradient functions, compute over a list of THETA matrices";
-1"we first define a network topology (the size of each layer)";
-1"it has been proven that a single hidden layer (with enough nodes)";
-1"can approximate any function.  in addition, extra layers add marginal value.";
-1"we present an example with a single hidden layer";
-1"the size of the first and last layer are fixed.";
-1"a good size for the middle layer is the average of the first and last";
n:0N!{(x;(x+y) div 2;y)}[count X;count Y]

-1"correctly picking the initial THETA values is important.";
-1"instead of setting them all to a 0 (or any constant value),";
-1"we must set them to randomn values to 'break the symmetry'.";
-1"additionally, we must chose values that ensure the gradient";
-1"of the sigmoid function is not too small.  .ml.glorotu does this";
0N!theta:2 raze/ THETA:.ml.glorotu'[1+-1_n;1_n];

rf:.ml.l2[1f];                  / regularization function
-1"the neural network cost function feeds the X values through the network,";
-1"then backpropagates the errors and gradient for each layer.";
-1"the cost and gradient calculations are expensive but share intermediate values";
-1"it is therefore important to compute both simultaneously";
hgolf:`h`g`o`l!`.ml.sigmoid`.ml.dsigmoid`.ml.sigmoid`.ml.logloss
show .ml.nncostgrad[rf;n;hgolf;Y;X;theta]

-1"in addition, it is important to confirm that the analytic gradient we compute";
-1"is the same (at least to a few significant digits)";
-1"as a discrete (and slower to calculate) gradient.";
.util.assert . a:.util.rnd[1e-6] .ml.checknngrad[1e-5;.ml.l2[.1];3 5 10 50 2;hgolf]
-1"confirming gradient of a few different activation and loss functions";
hgolf:`h`g`o`l!`.ml.relu`.ml.drelu`.ml.sigmoid`.ml.logloss
.util.assert . a:.util.rnd[1e-6] .ml.checknngrad[1e-5;();3 5 10 50 2;hgolf]
hgolf:`h`g`o`l!`.ml.relu`.ml.drelu`.ml.softmax`.ml.celoss
.util.assert . a:.util.rnd[1e-6] .ml.checknngrad[1e-5;();3 5 10 50 2;hgolf]
hgolf:`h`g`o`l!`.ml.lrelu`.ml.dlrelu`.ml.sigmoid`.ml.logloss
.util.assert . a:.util.rnd[1e-6] .ml.checknngrad[1e-5;();3 5 10 50 2;hgolf]
hgolf:`h`g`o`l!`.ml.tanh`.ml.dtanh`.ml.sigmoid`.ml.logloss
.util.assert . a:.util.rnd[1e-6] .ml.checknngrad[1e-5;();3 5 10 50 2;hgolf]
hgolf:`h`g`o`l!`.ml.tanh`.ml.dtanh`.ml.softmax`.ml.celoss
.util.assert . a:.util.rnd[1e-6] .ml.checknngrad[1e-5;();3 5 10 50 2;hgolf]
hgolf:`h`g`o`l!`.ml.tanh`.ml.dtanh`.ml.linear`.ml.mseloss
.util.assert . a:.util.rnd[1e-6] .ml.checknngrad[1e-5;();3 5 10 50 2;hgolf]
hgolf:`h`g`o`l!`.ml.linear`.ml.dlinear`.ml.linear`.ml.mseloss
.util.assert . a:.util.rnd[1e-6] .ml.checknngrad[1e-5;();3 5 10 50 2;hgolf]

hgolf:`h`g`o`l!`.ml.sigmoid`.ml.dsigmoid`.ml.softmax`.ml.celoss

-1"we can now run (batch) gradient descent across the whole datatset.";
-1"this will always move along the steepest gradient, but makes slow progress";
-1"and is prone to finding local minima";

first .fmincg.fmincg[5;.ml.nncostgrad[rf;n;hgolf;Y;X];theta];

/ NOTE: qml throws a `limit error (too many elements)
/.qml.minx[`quiet`full`iter,1;.ml.nncostgradf[rf;n;hgolf;Y;X];enlist theta]
-1"we can, alternatively, perform stochastic gradient descent (SGD).";
-1"by taking a subset of the data on each iteration, we can analyze all the data";
-1"without holding it all in memory simultaneously. in addition, the parameters will";
-1"jump around and therefore increasing the chance we find a global minima.";
-1"SGD converges faster, but might never stop iterating";
-1"";
/https://www.quora.com/Whats-the-difference-between-gradient-descent-and-stochastic-gradient-descent
-1"when the batch size is equal to the size of the data set,";
-1"SGD is equal to batch gradient descent.";
-1"at the other extreme, we can anlayize one observation at a time.";
-1"this is called 'on-line learning'";

-1"we first define a minimization projection:";
mf:{first .fmincg.fmincg[5;.ml.nncostgrad[rf;n;hgolf;Y[;y];X[;y]];x]}
-1"we then have a few choices to randomize the dataset.";
-1"A: permutate, then run n non-permuted epochs";
i:0N?count X 0
X:X[;i];Y:Y[;i];y@:i
theta:1 .ml.sgd[mf;til;10000;X]/ theta
-1"B: run n permuted epochs";
theta:1 .ml.sgd[mf;0N?;10000;X]/ theta
-1"C: run n random (with replacement) epochs (aka bootstrap)";
theta:1 .ml.sgd[mf;{x?x};10000;X]/ theta

-1"we can run any above example with cost threshold.";
theta:(1f<first .ml.nncostgrad[();n;hgolf;Y;X]::) .ml.sgd[mf;0N?;10000;X]/ theta

-1"what is the final cost?";
first .ml.nncostgrad[();n;hgolf;Y;X;theta]

-1"how well did we learn on the training data set?";
avg y=p:.ml.clfova .ml.nnpredict[hgolf;X] .ml.nncut[n] theta

-1"we can visualize the hidden features";
-1 plt 1_ rand first .ml.nncut[n] theta

-1"or view a few mistakes";
p w:where not y=p
do[2;-1 plt X[;i:rand w];show ([]p;y) i]

-1"how well can we predict unseen data";
avg yt=p:.ml.clfova .ml.nnpredict[hgolf;Xt] .ml.nncut[n] theta

-1"or view a few mistakes";
p w:where not yt=p
do[2;-1 plt Xt[;i:rand w];show ([]p;yt) i]

-1"we can view the confusion matrix as well";
show .util.totals[`TOTAL] .ml.cm[yt;"i"$p]

-1"neural networks are not limited to classification problems.";
-1"using a linear activation function on the output layer";
-1"along with a means squared (aka quadratic) error loss function";
-1"our feed forward neural network can be used for non-linear regression.";

-1"we split the wine quality data into train and test partitions";
d:`train`test!.ml.part[3 1] winequality.red.t
X:1_value flip d.train
Y:1#value flip d.train
-1"and then z-score the train and test data";
a:avg each X
sd:sdev each X
Xt:1_value flip d.test
Yt:1#value flip d.test
X:(X-a)%sd
Xt:(Xt-a)%sd


-1"next we define the topology";
n:{(x;(x+y) div 2;y)}[count X;count Y];
-1"add some regularization";
rf:.ml.l2[l2:10f];
-1"add initialize the THETA coefficients";
theta:2 raze/ .ml.heu'[1+-1_n;1_n];
-1"using the (leaky) rectified linear unit prevents vanishing gradients";
hgolf:`h`g`o`l!`.ml.lrelu`.ml.dlrelu`.ml.linear`.ml.mseloss
theta:first r:.fmincg.fmincg[1000;.ml.nncostgrad[rf;n;hgolf;Y;X];theta]

-1"before revealing how our non-linear neural network faired,";
-1"lets review the mse resulting from ridge regression on the train data";
THETA:.ml.ridge[0f,count[X]#l2;Y;.ml.prepend[1f]X]
.ml.lincost[();Y;X] THETA
-1"and the test data";
.ml.lincost[();Yt;Xt] THETA

-1"now we check for a reduction in the mse using the neural network";
.ml.nncost[();hgolf;Y;X] .ml.nncut[n] theta
-1"and the test data";
.util.assert[0.21625244670714813] 0N!.ml.nncost[();hgolf;Yt;Xt] .ml.nncut[n] theta
.util.assert[0.27492519074906702] sum .ml.nngrad[();hgolf;Yt;Xt] .ml.nncut[n] theta
