\d .ml

mm:mmu                          / X  * Y
mmt:{y$/:x}                     / X  * Y'
mtm:{flip[x]$y}                 / X' * Y
minv:inv                        / X**-1
mlsq:lsq                        / least squares
dot:$                           / dot product

cmul:{((-/)x*y;(+/)x*(|:)y)}    / complex multiplication
csqr:{((-/)x*x;2f*(*/)x)}       / complex square
cabs:{sqrt sum x*x}             / complex absolute value
mandelbrot:{[c;x]c+csqr x}      / mandelbrot
mbrot:{[c;x]c+((-/)i2;2f*(*/)i;x[2]+not 4f<0w^(+/)i2:i*i:2#x)}


prepend:{((1;count y 0)#x),y}
append:{y,((1;count y 0)#x)}
addint:prepend[1f]              / add intercept

predict:{[X;THETA]mm[THETA] addint X} / regression predict

/ regularized linear regression cost
rlincost:{[l;X;Y;THETA]
 J:sum (1f%2*n:count Y 0)*sum mmt[Y] Y-:predict[X;THETA];
 if[l>0f;J+:(l%2*n)*dot[x]x:raze @[;0;:;0f]'[THETA]];
 J}
lincost:rlincost[0f]

/ regularized linear regression gradient
rlingrad:{[l;X;Y;THETA]
 g:(1f%n:count Y 0)*mmt[predict[X;THETA]-Y] addint X;
 if[l>0f;g+:(l%n)*@[;0;:;0f]'[THETA]];
 g}
lingrad:rlingrad[0f]

/ regularized content-based filtering cost & gradient
rcbfcostgrad:{[l;X;Y;theta]
 THETA:(count Y;0N)#theta;
 J:.5*sum sum 0f^J*J:predict[X;THETA]-Y;
 if[l>0f;J+:(.5*l)*dot[x]x:raze @[;0;:;0f]'[THETA]];
 g:mmt[0f^predict[X;THETA]-Y] addint X;
 if[l>0f;g+:l*@[;0;:;0f]'[THETA]];
 (J;raze g)}
cbfcostgrad:rcbfcostgrad[0f]

/ regularized collaborative filtering cost
rcfcost:{[l;Y;THETA;X]
 J:.5*sum sum 0f^J*J:mtm[THETA;X]-Y;
 if[l>0f;J+:.5*l*sum sum over/:(THETA*THETA;X*X)];
 J}
cfcost:rcfcost[0f]

/ regularized collaborative filtering gradient
rcfgrad:{[l;Y;THETA;X]
 g:(mmt[X;g];mm[THETA] g:0f^mtm[THETA;X]-Y);
 if[l>0f;g+:l*(THETA;X)];
 g}
cfgrad:rcfgrad[0f]

/ collaborative filtering cut where n:(nu;nf)
cfcut:{[n;x](n[1],0N)#/:(0,prd n)_x}

/ regularized collaborative filtering cost & gradient
rcfcostgrad:{[l;Y;n;thetax]
 THETA:first X:cfcut[n] thetax;X@:1;
 J:.5*sum sum g*g:0f^mtm[THETA;X]-Y;
 g:(mmt[X;g];mm[THETA;g]);
 if[l>0f;J+:.5*l*sum sum over/:(THETA*THETA;X*X);g+:l*(THETA;X)];
 (J;2 raze/ g)}
cfcostgrad:rcfcostgrad[0f]

/ regularized collaborative filtering update one rating
/ (a)lpha: learning rate, (xy): coordinates of Y to update
rcfupd1:{[l;Y;a;THETAX;xy]
 e:(Y . xy)-dot . tx:THETAX .'i:flip(::;xy);
 THETAX:./[THETAX;0 1,'i;+;a*(e*reverse tx)-l*tx];
 THETAX}

/ accumulate cost by calling (c)ost (f)unction on the result of
/ (f)unction applied to x[1].  append resulting cost to x[0] and
/ return.
acccost:{[cf;f;x] (x[0],cf fx;fx:f x 1)}

/ return 1b until the improvement from the (c)ost is less than
/ the specified (p)ercent.
converge:{[p;c]
 b:$[1<n:count c;p<pct:neg -1f+c[n-1]%c[n-2];1b];
 s:"Iteration ",string[n]," | cost: ",string last c;
 1 s," | pct: ",string[pct],"\n\r"b;
 b}

/ (a)lpha: learning rate, gf: gradient function
gd:{[a;gf;THETA] THETA-a*gf THETA} / gradient descent

normeq:{mm[mmt[x;y]] minv mmt[y;y]} / normal equations

/ apply f (in parallel) to the 2nd dimension of x (instead of flipping x)
f2nd:{[f;x](f x .(::),) peach til count x 0}
/ center data
demean:{x-\:$[type x;avg;f2nd avg] x}
/ apply f to centered (then decenter)
fdemean:{[f;x]a+f x-\:a:$[type x;avg;f2nd avg] x}
/ feature normalization (centered/unit variance)
zscore:{
 x:x-\:$[t:type x;avg;f2nd avg] x;
 x:x%\:$[t;sdev;f2nd sdev] x;
 x}
/ apply f to normalized (then denormalize)
fzscore:{[f;x]
 x:x-\:a:$[t:type x;avg;f2nd avg] x;
 x:x%\:d:$[t;sdev;f2nd sdev] x;
 x:a+d*f x;
 x}

/ compute the average of the top n items
navg:{[n;x;y]f2nd[avg] y (n&count x)#idesc x}
/ compute the weighted average of the top n items
nwavg:{[n;x;y]sum[0^x*y i]%sum abs x@:i:(n&count x)#idesc x}

/ user-user collaborative filtering
/ (s)imilarity (f)unction, (a)veraging (f)unction
/ (R)ating matrix and new (r)ating vector
uucf:{[sf;af;R;r]af[sf[r] peach R;R]}

/ spearman's rank (tied value get averaged rank)
/srank:{(avg each rank[x] group x) x}
srank:{@[r;g;:;avg each (r:"f"$rank x) g@:where 1<count each g:group x]}
/ where not any null
wnan:{$[any 1_differ type each x;til count x;where not any null x]}
/ spearman's rank correlation
scor:{srank[x w] cor srank y w:wnan(x;y)}

sigmoid:{1f%1f+exp neg x}       / sigmoid function
softmax:{x%sum x:exp x}         / softmax function

lpredict:(')[sigmoid;predict]   / logistic regression predict
/ cross-entropy loss
celoss:{(-1f%count y 0)*sum sum each (y*log x)+(1f-y)*log 1f-x}

/ regularized logistic regression cost
/ expects a list of THETA matrices
rlogcost:{[l;X;Y;THETA]
 if[type THETA  ;:.z.s[l;X;Y] enlist THETA];     / vector
 if[type THETA 0;:.z.s[l;X;Y] enlist THETA];     / single matrix
 J:celoss[X lpredict/ THETA;Y];
 if[l>0f;J+:(l%2*count Y 0)*dot[x]x:2 raze/@[;0;:;0f]''[THETA]]; / regularize
 J}
logcost:rlogcost[0f]

bpg:{[THETA;a;D] / back prop gradient
 a:addint each -1_a;
 G:{[D;THETA;a]1_mtm[THETA;D]*a*1f-a}\[D;reverse 1_THETA;reverse 1_a];
 G,:enlist D;
 g:(G mmt' a)%count D 0;
 g}

/ regularized logistic regression gradient
/ expects a list of THETA matrices
rloggrad:{[l;X;Y;THETA]
 if[type THETA  ;:first .z.s[l;X;Y] enlist THETA]; / vector
 if[type THETA 0;:first .z.s[l;X;Y] enlist THETA]; / single matrix
 n:count Y 0;
 a:lpredict\[enlist[X],THETA];
 g:bpg[THETA;a] last[a]-Y;            / back prop
 if[l>0f;g+:(l%n)*@[;0;:;0f]''[THETA]]; / regularize
 g}
loggrad:rloggrad[0f]

rlogcostgrad:{[l;X;Y;THETA]
 J:sum rlogcost[l;X;Y;THETA];
 g:rloggrad[l;X;Y;THETA];
 (J;g)}
logcostgrad:rlogcostgrad[0f]

rlogcostgradf:{[l;X;Y]
 Jf:(sum rlogcost[l;X;Y]@);
 gf:(enlist rloggrad[l;X;Y]@);
 (Jf;gf)}
logcostgradf:rlogcostgradf[0f]

/ normalized initialization - Glorot and Bengio (2010)
ninit:{sqrt[6f%x+y]*-1f+(x+:1)?/:y#2f}

/ (m)inimization (f)unction, (c)ost (g)radient (f)unction
onevsall:{[mf;cgf;Y;lbls] (mf cgf "f"$Y=) peach lbls}

imax:{x?max x}                  / index of max element
imin:{x?min x}                  / index of min element

/ predict each number and pick best
predictonevsall:{[X;THETA]f2nd[imax] X lpredict/ THETA}

/ binary classification evaluation metrics (summary statistics)

/ given expected boolean values x and observered value y, compute
/ (tp;tn;fp;fn)
tptnfpfn:{sum each (x;nx;x;nx:not x)*(y;ny;ny:not y;y)}

/ aka rand measure (William M. Rand 1971)
accuracy:{sum[x 0 1]%sum x}
precision:{x[0]%sum x 0 2}
recall:{x[0]%sum x 0 3}

/ f measure: given (b)eta and x:tptnfpfn
/ harmonic mean of precision and recall
F:{[b;x]
 f:(p:precision x)*(r:recall x)*1+b2:b*b;
 f%:r+p*b2;
 f}
F1:F[1]

/ Fowlkes–Mallows index (E. B. Fowlkes & C. L. Mallows 1983)
/ geometric mean of precision and recall
FM:{x[0]%sqrt sum[x 0 2]*sum x 0 3}

/ returns a number between 0 and 1 which indicates the similarity
/ between two datasets
jaccard:{x[0]%sum x _ 1}

/ Matthews Correlation Coefficient
/ geometric mean of the regression coefficients of the problem and its dual
/ -1 0 1 (none right, same as random prediction, all right)
MCC:{ ((-). x[0 2]*x 1 3)%prd sqrt x[0 0 1 1]+x 2 3 2 3}

/ confusion matrix
cm:{
 n:count u:asc distinct x,y;
 m:./[(n;n)#0;flip (u?y;u?x);1+];
 t:([]x:u)!flip (`$string u)!m;
 t}

/ cross validation
cv:{[f;ys;Xs;i]
 X:(,'/)Xs _ i; / drop i and raze
 y:raze ys _ i; / drop i and raze
 e:(ys i)=.ml.f2nd[f[y;X]] Xs i; / compute equality
 e}

/ neural network cut
nncut:{[n;x](1+-1_n) cut' (sums {x*y+1} prior -1_n) cut x}
diag:{$[0h>t:type x;x;@[n#abs[t]$0;;:;]'[til n:count x;x]]}

/ (f)unction, x, (e)psilon
/ compute partial derivatives if e is a list
numgrad:{[f;x;e](.5%e)*{x[y+z]-x[y-z]}[f;x] peach diag e}

checknngradients:{[l;n]
 theta:2 raze/ THETA:ninit'[-1_n;1_n];
 X:flip ninit[-1+n 0;n 1];
 y:1+(1+til n 1) mod last n;
 YMAT:flip diag[last[n]#1f]"i"$y-1;
 g:2 raze/ rloggrad[l;X;YMAT] THETA; / analytic gradient
 f:(rlogcost[l;X;YMAT]nncut[n]@);
 ng:numgrad[f;theta] count[theta]#1e-4; / numerical gradient
 (g;ng)}

checkcfgradients:{[l;n]
 nu:n 0;nm:10 ;nf:n 1;          / n users, n movies, n features
 Y:dot[nf?/:nu#1f]nm?/:nf#1f;   / random recommendations
 Y*:0N 1@.5<nm?/:nu#1f;         / drop some recommendations
 thetax:2 raze/ (THETA:nu?/:nf#1f;X:nm?/:nf#1f); / random initial parameters
 g:2 raze/ rcfgrad[l;Y;THETA;X];                 / analytic gradient
 f:(rcfcost[l;Y] . cfcut[n]@);
 ng:numgrad[f;thetax] count[thetax]#1e-4; / numerical gradient
 (g;ng)}


/ n can be any network topology dimension
nncostgrad:{[l;n;X;YMAT;theta] / combined cost and gradient for efficiency
 THETA:nncut[n] theta;
 Y:last a:lpredict\[enlist[X],THETA];
 n:count YMAT 0;
 J:celoss[Y;YMAT];
 if[l>0f;J+:(l%2*n)*{dot[x]x}2 raze/ @[;0;:;0f]''[THETA]]; / regularize
 g:bpg[THETA;a] Y-YMAT;
 if[l>0f;g+:(l%n)*@[;0;:;0f]''[THETA]]; / regularize
 (J;2 raze/ g)}

nncostgradf:{[l;n;X;YMAT]
 Jf:(first nncostgrad[l;n;X;YMAT]@);
 gf:(last nncostgrad[l;n;X;YMAT]@);
 (Jf;gf)}

/ stochastic gradient descent

/ successively call (m)inimization (f)unction with (THETA) and
/ randomly sorted (n)-sized chunks generated by (s)ampling (f)unction
sgd:{[mf;sf;n;X;THETA]THETA mf/ n cut sf count X 0}

/ (w)eighted (r)egularized (a)lternating (l)east (s)quares
wrals:{[l;Y;THETAX]
 X:THETAX 1;
 THETA:flip updals[l;X] peach Y;
 X:flip f2nd[updals[l;THETA]] Y;
 (THETA;X)}
updals:{[l;M;y]
 l:diag count[M:M[;w]]#l*count w:where not null y;
 v:first mlsq[enlist mm[M;y w]] mmt[M;M]+l;
 v}

/ k-means
edist2:{sum x*x-:y}             / euclidian distance squared
edist:(')[sqrt;edist2]          / euclidian distance
/pedist2:{sum[x*x]+/:sum[y*y]+-2f*mtm[y;x]} / pairwise edist2
pedist2:{sum[x*x]+/:sum[y*y]+-2f*f2nd[sum x*;y]} / pairwise edist2
mdist:{sum abs x-y}             / manhattan distance (taxicab metric)
mkdist:{sum[abs[z-y] xexp x] xexp 1f%x} / minkowski distanace
hmean:{1f%avg 1f%x}             / harmonic mean

lntf:{1f+log x}                    / log normalized term frequency
dntf:{[k;x]k+(1f-k)*x% max each x} / double normalized term frequenecy

idf: {log count[x]%sum 0<x}     / inverse document frequency
idfs:{log 1f+count[x]%sum 0<x}  / inverse document frequency smooth
idfm:{log 1f+max[x]%x:sum 0<x}  / inverse document frequency max
pidf:{log (max[x]-x)%x:sum 0<x} / probabilistic inverse document frequency
tfidf:{[tff;idff;x]tff[x]*\:idff x}
cossim:{(sum x*y)%sqrt(sum x*x@:w)*sum y*y@:w:wnan(x;y)} / cosine similarity
cosdist:(')[1f-;cossim]                  / cosine distance

/ using the (d)istance (f)unction, cluster the data (X) into groups
/ defined by the closest (C)entroid
cgroup:{[df;X;C] group f2nd[imin] f2nd[df X] C}

/ return the index of n (w)eighted samples
iwrand:{[n;w]s binr n?last s:sums w}
/ find n (w)eighted samples of x
wrand:{[n;w;x]x iwrand[n] w}

/ kmeans++ initialization algorithm
/ using (d)istance (f)function and data X, append the next cluster
/ to the pair (min cluster (d)istance;all (C)lusters)
kmeanspp:{[df;X;dC]
 d:dC[0]&d*d:df[X] last C:dC 1;
 C,:enlist X@\: first iwrand[1] d;
 (d;C)}

/ k-(means|medians) algorithm

/ stuart lloyd's algorithm. using a (d)istance (f)unction and
/ (m)ean/edian (f)unction, find (k)-centroids in the data (X) starting
/ with a (C)entroid list. if C is an atom, use it to randomly
/ initialize C. if positive, use k-means++ method to pick k centroids
/ that are purposefully distant from each other. if negative, use
/ "Forgy" method and randomly pick k centroids.
lloyd:{[df;mf;X;C]
 if[not t:type C;C:cgroup[df;X;C];t:99h]; / assign step
 if[99h=t;:mf''[X@\:value C]];            / update step
 if[0>C;:X@\:C?count X 0];                / forgy
 C:flip last (C-1) kmeanspp[df;X]/ (df[X] c;enlist c:X@\:rand count X 0);
 C}

kmeans:lloyd[edist;avg]
kmedians:lloyd[mdist;med]
khmeans:lloyd[edist;hmean]

/ using the (d)istance (f)unction, cluster the data (X) into groups
/ defined by the closest (C)entroid and return the distance
cdist:{[df;X;C] k!df[X@\:value g] C@\:k:key g:cgroup[df;X;C]}
ecdist:cdist[edist]
mcdist:cdist[mdist]

distortion:sum sum each

/ ungroup (inverse of group)
ugrp:{(key[x] where count each value x)iasc raze x}

/ dimensionality reduction

covm:{[X] mmt[X;X]%count X 0}     / covariance matrix
pca:{[X] last .qml.mev covm X}    / eigen vectors of scatter matrix
project:{[V;X] mtm[V] mm[V;X]}    / project X onto subspace V

/ lance-williams algorithm update functions
single:{.5 .5 0 -.5}
complete:{.5 .5 0 .5}
average:{(x%sum x _:2),0 0f}
weighted:{.5 .5 0 0}
centroid:{((x,neg prd[x]%s)%s:sum x _:2),0f}
ward:{((k+/:x 0 1),(neg k:x 2;0f))%\:sum x}

/ implementation of lance-williams algorithm for performing
/ hierarchical agglomerative clustering. given (l)inkage (f)unction to
/ determine distance between new and remaining clusters and
/ (d)issimilarity (m)atrix, return (from;to;distance;#elements).  lf
/ in `single`complete`average`weighted`centroid`ward
lw:{[lf;dm]
 n:count dm 0;
 if[0w=d@:i:imin d:(n#dm)@'dm n;:dm]; / find closest clusters
 j:dm[n] i;                           / find j
 c:lf (count each group dm[n+1])@/:(i;j;til n); / determine coefficients
 nd:sum c*nd,d,enlist abs(-/)nd:dm(i;j);        / calc new distances
 dm[til n;i]:dm[i]:nd;                          / update distances
 dm[i;i]:0w;                                    / fix diagonal
 dm[j;(::)]:0w;                                 / erase j
 dm[til n+2;j]:(n#0w),i,i;    / erase j and set aux data
 dm[n]:imin peach n#dm;       / find next closest element
 dm[n+1;where j=dm n+1]:i;    / all elements in cluster j are now in i
 dm:@[dm;n+2 3 4 5;,;(j;i;d;count where i=dm n+1)];
 dm}

/ given a (d)istance (f)unction and (l)inkage (f)unction, construct the
/ linkage (dendrogram) statistics of data in X
linkage:{[df;lf;X]
 dm:f2nd[df X] X;                         / dissimilarity matrix
 dm:./[dm;flip (i;i:til count X 0);:;0w]; / ignore loops
 dm,:enlist imin peach dm;
 dm,:enlist til count dm 0;
 dm,:4#();
 l:-4#lw[lf] over dm;
 l}

/ merge node y[0] into y[1] in tree x
graft:{@[x;y;:;(::;x y)]}

/ build a complete dendrogram from linkage data x
tree:{1#(til[1+count x],(::)) graft/ x}

/ cut a single layer off tree
slice:{
 if[type x;:x];
 if[type f:first x;:(1_x),f];
 if[type ff:first f;:(1_f),(1_x),ff]
 f,:1_x;
 f}

/ binomial pdf (not atomic because of factorial)
binpdf:{[n;p;k]
 if[0<max type each (n;p;k);:.z.s'[n;p;k]];
 r:prd[1+k+til n]%prd 1+til n-:k;
 r*:prd (p;1f-p) xexp (k;n);
 r}

/ binomial log likelihood (for multinomial set n=0)
binll:{[n;p;k](k*log p)+$[n;(n-k)*log 1f-p;0f]}
/ binomial likelihood approximation (without the coefficient)
binla:{[n;p;k](p xexp k)*$[n;(1f-p) xexp n-k;1f]}
/ binomial maximum likelihood
binml:{[n;x;w]$[type x;1#w wavg x%n;x .z.s[n]\: w]}

/ multinomial log likelhood
multill:binll[0]
/ multinomial likelihood approximation
multila:binla[0]
/ multinomial maximum likelihood (where n is for add n smoothing)
multiml:{[n;x;w]$[type x;1#w wsum x%n;(x:x,'n) .z.s[sum/[x]]\: w,1f]}
/ gaussian kernel
gaussk:{[mu;s2;x] exp (sum x*x-:mu)%-2*s2}

/ gaussian
gauss:{[mu;s2;x]
 p:exp (x*x-:mu)%-2*s2;
 p%:sqrt 2f*s2*acos -1f;
 p}

/ gaussian multivariate
gaussmv:{[mu;s2;X]
 if[type s2;s2:diag count[X]#s2];
 p:exp -.5*sum X*mm[minv s2;X-:mu];
 p*:sqrt 1f%.qml.mdet s2;
 p*:(2f*acos -1f) xexp -.5*count X;
 p}

/ gaussian maximum likelihood
gaussml:{[x;w]$[type x;(mu;w wavg x*x-:mu:w wavg x);x .z.s\: w]}
/ gaussian maximum likelihood multi variate
gaussmlmv:{[X;w](mu;w wavg X (*\:/:)' X:flip X-mu:w wavg/: X)}

/ guassian log likelihood
gaussll:{[mu;s2;X] -.5*sum (log 2f*acos -1f;log s2;(X*X-:mu)%s2)}

/ (l)ikelhood (f)unction, (m)aximization (f)unction
/ with prior probabilities (p)hi and distribution parameters (t)heta
em:{[lf;mf;X;pt]                      / expectation maximization
 if[a:0h>type pt;pt:enlist pt#1f%pt]; / default to equal prior probabilities
 l:$[a;count[$[type X;X;X 0]]?/:count[pt 0]#1f;(@[;X]lf .)peach flip 1_pt];
 W:p%\:sum p:l*phi:pt 0;          / weights (responsibilities)
 if[0h<type phi;phi:avg peach W]; / new prior probabilities
 theta:flip mf[X] peach W;        / new coefficients
 enlist[phi],theta}

/ return value which occurs most frequently
nmode:{imax count each group x} / naive mode
mode:{x -1+w imax deltas w:where differ[x:asc x],1b}
wmode:{[w;x]imax sum each w group x} / weighted mode

/ k nearest neighbors

/ pick k closest values to x from training data X and return the
/ (c)lassification that occurs most frequently
knn:{[df;k;c;X;x](mode c #[;iasc df[X;x]]@) each k}

/ markov clusetering

addloop:{x|diag max peach x|flip x}

expand:{[e;X](e-1)mm[X]/X}

inflate:{[r;p;X]
 X:X xexp r;                             / inflate
 X*:$[-8h<type p;(p>iasc idesc@)';p<] X; / prune
 X%:sum peach X;                         / normalize
 X}

/ if (p)rune is an integer, take p largest, otherwise take everything > p
mcl:{[e;r;p;X] inflate[r;p] expand[e] X}

chaos:{max {max[x]-sum x*x} peach x}
interpret:{1_asc distinct f2nd[where] 0<x}

/ naive bayes

/ fit parameters given (m)aximization (f)unction
/ returns a dictionary with prior and conditional likelihoods
fitnb:{[mf;w;X;y]
 g:prepend[w;X]@\:/:group y;
 g:{count[y],x[1_y;first y]}[mf] peach g;
 g}
/ using a [log]likelihood (f)unction and (cl)assi(f)ication compute
/ densities for X
densitynb:{[f;clf;X]clf[;0],'(1_'clf) {(x . y) z}[f]'\: X}
/ given dictionary of sample densities, compute posterior probabilities
probabilitynb:{[d]d%\:sum d}
/ given prior (p)robabilities and a dictionary of sample densities,
/ predict class
predictnb:{[d] imax each flip prd flip d}
/ given prior (p)robabilities and a dictionary of sample log
/ densities, predict class
lpredictnb:{[d] imax each flip sum @[flip d;0;log]}

/ decision trees

/ weighted odds
odds:{[w;g]g%sum g:sum each w g}

/ splitting functions
entropy:{[w;x]neg sum x*2 xlog x:odds[w] group x}
gini:{[w;x]1f-sum x*x:odds[w] group x}
sse:{[w;x]sum x*x-:w wavg x}

/ create all combinations of length x from a list (or size of) y
cmb:{
 if[not 0>type y;:y .z.s[x] count y];
 if[null x;:raze .z.s[;y] each 1+til y];
 c:flip enlist flip enlist til y-:x-:1;
 c:raze c {(x+z){raze x,''y}'x#\:y}[1+til y]/til x;
 c}

/ using a (s)plit (f)unction to compute the information gain
/ (optionally (n)ormalized by splitinfo) of x and y
gain:{[n;sf;w;x;y]
 g:sf[w] x;
 g-:sum odds[w;gy]*(not null key gy)*w[gy] sf' x gy:group y;
 if[n;g%:sf[w] y];              / gain ratio
 (g;::;gy)}

/ set gain
sgain:{[sf;w;x;y]
 g:(gain[0b;sf;w;x] y in) peach u:cmb[0N] distinct y;
 g@:i:imax g[;0];               / highest gain
 g[1]:in[;u i];                 / split function
 g}

/ improved use of ordered attributes in c4.5 (quinlan) MDL
ogain:{[mdl;n;sf;w;x;y]
 g:(gain[0b;sf;w;x] y <) peach u:desc distinct y;
 g@:i:imax g[;0];               / highest gain (not gain ratio)
 g[1]:<[;avg u i+0 1];          / split function
 if[mdl;g[0]-:xlog[2;-1+count u]%count x];
 if[n;g[0]%:sf[w] ugrp g 2];    / convert to gain ratio
 g}

isord:{type[x] in 8 9 15h} / is ordered

/ given a (t)able of classifiers and labels where the first column is
/ target attribute create a decision tree using the (c)ategorical
/ (g)ain (f)unction and (o)rdered (g)ain (f)unction.  the (s)plit
/ (f)unction decides what statistic to minimize.  pruning subtrees
/ with (m)inimum number of (l)eaves, and (m)ax (d)epth
dt:{[cgf;ogf;sf;ml;md;w;t]
 if[(::)~w;w:n#1f%n:count t];       / handle unassigned weight
 if[1=count d:flip t;:(w;first d)]; / no features to test
 if[not md;:(w;first d)];           / don't split deeper than max depth
 if[not ml<count a:first d;:(w;a)]; / don't split unless >min leaves
 if[all 1_(=':) a;:(w;a)];          / all values are equal
 d:(0N?key d)#d:1 _d;               / randomize feature order
 g:{[cgf;ogf;sf;w;x;y] $[isord y;ogf;cgf][sf;w;x;y]}[cgf;ogf;sf;w;a] peach d;
 if[all 0>=gr:first each g;:(w;a)]; / stop if no gain
 g:last b:1_ g ba:imax gr;          / best attribute
 / distribute nulls down each branch with reduced weight
 if[(c:count k)>ni:null[k:key g]?1b;w:@[w;n:g nk:k ni;%;c-1];g:(nk _g),\:n];
 if[null b 0;t:(1#ba)_t];           / don't reuse categorical classifiers
 b[1]:.z.s[cgf;ogf;sf;ml;md-1]'[w g;t g];   / classify subtree
 ba,b}


/ wilson score - binary confidence interval (Edwin Bidwell Wilson)
wscore:{[z;f;n](f+(.5*z2n)+-1 1f*z*sqrt((.25*z2n)+f-f*f)%n)%1f+z2n:z*z%n}
/ pessimistic error
perr:{[z;w;x]last wscore[z;(1f-avg x=wmode[w;x]);count x]}

/ use (e)rror (f)unction to post-prune (t)able
prune:{[ef;t]
 if[2=count t;:t];               / (w;a)
 b:value t[2]:.z.s[ef] each t 2; / prune subtree
 if[any 3=count each b;:t];      / can't prune
 e:ef . wa:(,') over b;          / pruned error
 if[e<((sum first@) each b) wavg (ef .) each b;:wa];
 t}

/ decision tree mode
dtmode:{[w;x]$[isord x;wavg;wmode][w;x]}

/ decision tree classifier: classify the (d)ictionary based on
/ decision (tr)ee
dtc:{[tr;d] dtmode . wx:dtcr[tr;d]}
dtcr:{[tr;d]                    / recursive component
 if[2=count tr;:tr];            / (w;a)
 if[not null k:d tr 0;if[(a:tr[1][k]) in key tr[2];:.z.s[tr[2] a;d]]];
 v:(,') over tr[2] .z.s\: d;    / dig deeper for null values
 v}

/ print leaf: prediction followd by classification error% or regresssion sse
pleaf:{[w;x]
 v:dtmode[w;x];                 / value
 e:$[isord x;string sum e*e:v-x;string[.1*"i"$1e3*1f-avg x = v],"%"];
 s:string[v], " (n = ", string[count x],", err = ",e, ")";
 s}

/ print (tr)ee with i(n)dent
ptree:{[n;tr]
 if[not n;:"root: ",(pleaf . first xs),last xs:.z.s[n+1;tr]];
 if[0h<type tr 0;:(tr;"")];
 s:1#"\n";
 s,:raze[(n)#enlist "|  "],raze string[tr 0 1],\:" ";
 s:s,/:string k:asc key tr 2;
 c:.z.s[n+1] each tr[2]k;        / child
 x:first each c;
 s:s,'": ",/:(pleaf .) each x;
 s:raze s,'last each c;
 x:(,') over x;
 (x;s)}

/ print a single node for graphviz
pnode:{[p;l;tr]
 s:string[i:I+:1], " [label=\""; / 'I' shared across leaves
 c:$[0h<type tr 0;enlist (tr;());.z.s'[i;key tr 2;value tr 2]];
 x:(,') over first each c;
 s,:pleaf . x;
 if[0h>type tr 0;s,:"\\n",raze string[tr 0 1],\: " "];
 s:enlist s,"\"] ;";
 if[i>0;s,:enlist string[p]," -> ",string[i]," [label=\"",string[l],"\"] ;"];
 s,:raze last each c;
 (x;s)}

/ print graph text for use with the 'dot' graphviz command, graph-easy
/ or http://webgraphviz.com
pgraph:{[tr]
 s:enlist "digraph Tree {";
 s,:enlist "node [shape=box] ;";
 s,:last pnode[I::-1;`;tr]; / reset global variable used by pnode
 s,:1#"}";
 s}

/ given a (t)able of classifiers and labels where the first column is
/ target attribute, create a decision tree
aid:dt[sgain;ogain[0b;0b];sse] / automatic interaction detection
id3:dt[gain[0b];gain[0b];entropy;1;0W;::] / iterative dichotomizer 3
q45:dt[gain[1b];ogain[1b;1b];entropy] / like c4.5 (but does not post-prune)
ct:dt[gain[0b];ogain[0b;1b];gini]     / classification tree
rt:dt[gain[0b];ogain[0b;0b];sse]      / regression tree
stump:dt[gain[0b];ogain[0b;1b];entropy;1;1]

/ (t)rain (f)unction, (c)lassifier (f)unction, (t)able,
/ (alpha;model;weights)
adaboost:{[tf;cf;t;amw]
 w:last amw;
 m:tf[w] t;                     / train model
 yh:cf[m] each t;               / predict
 e:sum w*not yh=y:first flip t; / weighted error
 a:.5*log (1f-e)%e;             / alpha
 w*:exp neg a*y*yh;             / up/down weight
 w%:sum w;                      / scale
 (a;m;w)}

/ Bootstrap AGgregating
bag:{[b;f;t](f ?[;t]@) peach b#count t}

/ Random FOrest
rfo:{[b;p;f;t]bag[b;(f{0!(x?1_cols y)#/:1!y}[p]@);t]}

/ sparse matrix manipulation

shape:{$[0h>t:type x;();n:count x;n,.z.s x 0;1#0]}
dim:count shape@
/ matrix overload of where
mwhere:{
 if[type x;:where x];
 x:.z.s each x;
 x:til[count x]{enlist[count[first y]#x],y:$[type y;enlist y;y]}'x;
 x:(,') over x;
 x}
/ sparse from matrix
sparse:{enlist[shape x],i,enlist (x') . i:mwhere not 0=x}
/ matrix from sparse
full:{./[x[0]#0f;flip x 1 2;:;x 3]}
/ sparse matrix transpose
smt:{(reverse x 0;x 2;x 1;x 3)}
/ sparse matrix multiplication
smm:{
 t:ej[`;flip ``c`v!1_y;flip`r``w!1_x];
 t:0!select sum w*v by r,c from t;
 m:enlist[(x[0;0];y[0;1])],value flip t;
 m}
/ sparse matrix addition
sma:{
 t:flip[`r`c`v!1_y],flip`r`c`v!1_x;
 t:0!select sum v by r,c from t;
 m:enlist[x 0],value flip t;
 m}

/ given a (p)robability of random surfing and (A)djacency matrix
/ obtain the page rank algebraically by matrix inversion
pageranka:{[p;A]
 A:((1f-p)%n:count A)+p*A%1|sum each A;
 r%:sum r:first mlsq[enlist r] diag[r:n#1f]-A;
 r}

/ given a (p)robability of random surfing, (A)djacency matrix and
/ (r)ank vector, obtain a better ranking (iterative model)
pageranki:{[p;A;r]
 s:sum r*0=d:sum each A;
 r:((1f-p)%n)+p*mtm[A;r%1|d]+s%n:count A;
 r}

/ given a (p)robability of random surfing, (S)parse adjacency matrix
/ and (r)ank vector, obtain a better ranking (iterative model)
pageranks:{[p;S;r]
 s:sum r*e:0=d:0^sum'[S[3] group S 1]til first S 0;
 r:((1f-p)%n)+p*first .ml.full[.ml.smm[.ml.sparse enlist r%1|d;S]]+s%n:S[0;0];
 r}

/ given a (p)robability of random surfing and (A)djacency matrix
/ create the markov Google matrix
google:{[p;A]
 e:0=d:sum each A;
 r:((1f-p)%n)+p*(A%1|d)+e%n:count A;
 r}

/ top n svd factors
nsvd:{[n;usv]n#''@[usv;1;(n:min n,count each usv 0 2)#]}

/ use svd decomposition to predict missing exposures for new user
/ (ui=0b) or item (ui=1b) (r)ecord
foldin:{[usv;ui;r]@[usv;0 2 ui;,;mm[enlist r] mm[usv 2 0 ui] minv usv 1]}
