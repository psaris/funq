\d .ml

prepend:{((1;count y 0)#x),y}
append:{y,((1;count y 0)#x)}
addint:prepend[1f]              / add intercept

predict:{[X;THETA]THETA$addint X} / regression predict

/ regularized linear regression cost
rlincost:{[l;X;Y;THETA]
 J:sum (1f%2*n:count Y 0)*sum Y$/:Y-:predict[X;THETA];
 if[l>0f;J+:(l%2*n)*x$x:raze @[;0;:;0f]'[THETA]];
 J}
lincost:rlincost[0f]

/ regularized linear regression gradient
rlingrad:{[l;X;Y;THETA]
 g:(1f%n:count Y 0)*addint[X]$/:predict[X;THETA]-Y;
 if[l>0f;g+:(l%n)*@[;0;:;0f]'[THETA]];
 g}
lingrad:rlingrad[0f]

/ regularized collaborative filtering cost
rcfcost:{[l;Y;THETA;X]
 J:.5*sum sum 0f^J*J:(THETA$X)-Y;
 if[l>0f;J+:.5*l*sum sum over/:(THETA*THETA;X*X)];
 J}
cfcost:rcfcost:[0f]

/ regularized collaborative filtering gradient
rcfgrad:{[l;Y;THETA;X]
 g:(X$/:g;flip[THETA]$g:0f^(THETA$X)-Y);
 if[l>0f;g+:l*(THETA;X)];
 g}
cfgrad:rcfgrad[0f]

/ collaborative filtering cut where n:(nu;nm;nf)
cfcut:{[n;x](1_n) cut' (0,prd 2#n) cut x}

/ regularized collaborative filtering cost & gradient
rcfcostgrad:{[l;Y;n;thetax]
 X:last THETAX:cfcut[n] thetax;THETA:first THETAX;
 J:.5*sum sum g*g:0f^(THETA$X)-Y;
 g:(X$/:g;flip[THETA]$g);
 if[l>0f;J+:.5*l*sum sum over/:(THETA*THETA;X*X);g+:l*(THETA;X)];
 (J;2 raze/ g)}
cfcostgrad:rcfcostgrad[0f]

/ gf: gradient function
gd:{[alpha;gf;THETA] THETA-alpha*gf THETA} / gradient descent

mlsq:{flip inv[y$/:y]$x$/:y}    / normal equations

/ center data
demean:{x-$[type x;avg;avg each]x}
/ apply f to centered (then decenter)
fdemean:{[f;x]a+f x-a:$[type x;avg;avg each]x}
/ feature normalization (centered/unit variance)
zscore:{x%$[t;sdev;sdev each]x-:$[t:type x;avg;avg each]x}
/ apply f to normalized (then denormalize)
fzscore:{[f;x]a+d*f x%d:$[t;sdev;sdev each]x-:a:$[t:type x;avg;avg each] x}

/ compute the average of the top n items 
navg:{[n;x;y]avg y (n&count x)#idesc x}
/ compute the weighted average of the top n items 
nwavg:{[n;x;y](x$y i)%sum abs x@:i:(n&count x)#idesc x}

/ user-user collaborative filtering
/ (s)imilarity (f)unction, (a)veraging (f)unction
/ (R)ating matrix and new (r)ating vector
uucf:{[sf;af;R;r]af[sf[r] peach R;R]}

/ spearman's rank (tied value get averaged rank)
/srank:{(avg each rank[x] group x) x}
srank:{@[r;g;:;avg each (r:"f"$rank x) g@:where 1<count each g:group x]}
/ spearman's rank correlation
scor:{srank[x] cor srank y}

sigmoid:{1f%1f+exp neg x}       / sigmoid function

lpredict:(')[sigmoid;predict]   / logistic regression predict

/ logistic regression cost
lcost:{sum (-1f%count y 0)*sum each (y*log x)+(1f-y)*log 1f-x}

/ regularized logistic regression cost
rlogcost:{[l;X;Y;THETA]
 J:lcost[X lpredict/ THETA;Y];
 if[l>0f;J+:(l%2*count Y 0)*x$x:2 raze/ @[;0;:;0f]''[THETA]]; / regularization
 J}
logcost:rlogcost[0f]

/ regularized logistic regression gradient
rloggrad:{[l;X;Y;THETA]
 n:count Y 0;
 a:lpredict\[enlist[X],THETA];
 D:last[a]-Y;
 a:addint each -1_a;
 D:{[D;THETA;a]1_(flip[THETA]$D)*a*1f-a}\[D;reverse 1_THETA;reverse 1_a],enlist D;
 g:(a($/:)'D)%n;
 if[l>0f;g+:(l%n)*@[;0;:;0f]''[THETA]]; / regularization
 g}
loggrad:rloggrad[0f]

rlogcostgrad:{[l;X;Y;THETA]
 J:sum rlogcost[l;X;Y;2 enlist/ THETA];
 g:2 raze/ rloggrad[l;X;Y;2 enlist/ THETA];
 (J;g)}
logcostgrad:rlogcostgrad[0f]

rlogcostgradf:{[l;X;Y]
 Jf:(sum rlogcost[l;X;Y]enlist enlist@);
 gf:(raze rloggrad[l;X;Y]enlist enlist @);
 (Jf;gf)}
logcostgradf:rlogcostgradf[0f]

/ normalized initialization - Glorot and Bengio (2010)
ninit:{sqrt[6f%x+y]*-1f+(x+:1)?/:y#2f}

/ (m)inimization (f)unction, (c)ost (g)radient (f)unction
onevsall:{[mf;cgf;Y;lbls] (mf cgf "f"$Y=) peach lbls}

imax:{x?max x}                  / index of max element
imin:{x?min x}                  / index of min element

/ predict each number and pick best
predictonevsall:{[X;THETA]imax each flip X lpredict/ THETA}

/ confusion matrix
cm:{
 n:count u:asc distinct x,y;
 m:.[;;1+]/[(n;n)#0;flip (u?y;u?x)];
 t:([]x:u)!flip (`$string[u])!m;
 t}

/ load mnist dataset
ldmnist:{
 d:first (1#4;1#"i") 1: 4_(h:4*1+x 3)#x;
 x:d#$[0>i:x[2]-0x0b;::;first ((2 4 4 8;"hief")@\:i,()) 1:] h _x;
 x}

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
 nu:n 0;nf:n 1;nm:n 2;          / num users, num features, num movies
 Y:(nf?/:nu#1f)$nm?/:nf#1f; / random recommendations
 Y*:0N 1@.5<nm?/:nu#1f;         / drop some recommendations
 thetax:2 raze/ (THETA:nf?/:nu#1f;X:nm?/:nf#1f); / random initial parameters
 g:2 raze/ rcfgrad[l;Y;THETA;X];                 / analytic gradient
 f:(rcfcost[l;Y] . cfcut[n]@);
 ng:numgrad[f;thetax] count[thetax]#1e-4; / numerical gradient
 (g;ng)}


/ n can be any network topology dimension
nncost:{[l;n;X;YMAT;theta] / combined cost and gradient for efficiency
 THETA:nncut[n] theta;
 Y:last a:lpredict\[enlist[X],THETA];
 n:count YMAT 0;
 J:lcost[Y;YMAT];
 if[l>0f;J+:(l%2*n)*{x$x}2 raze/ @[;0;:;0f]''[THETA]]; / regularization
 D:Y-YMAT;
 a:addint each -1_a;
 D:{[D;THETA;a]1_(flip[THETA]$D)*a*1f-a}\[D;reverse 1_THETA;reverse 1_a],enlist D;
 g:(a($/:)'D)%n;
 if[l>0f;g+:(l%n)*@[;0;:;0f]''[THETA]]; / regularization
 (J;2 raze/ g)}

nncostf:{[l;n;X;YMAT]
 Jf:(first nncost[l;n;X;YMAT]@);
 gf:(last nncost[l;n;X;YMAT]@);
 (Jf;gf)}

/ stochastic gradient descent

/ successively call (m)inimization (f)unction with (THETA) and
/ randomly sorted (n)-sized chunks generated by (s)ampling (f)unction
sgd:{[mf;sf;n;X;THETA]THETA mf/ n cut sf count X 0}

/ k-means

edist:{sum x*x-:y}              / euclidian distance
mdist:{sum abs x-y}             / manhattan distance (taxicab metric)
hmean:{1f%avg 1f%x}             / harmonic mean

cossim:{(sum x*y)%sqrt(sum x*x)*sum y*y} / cosine similarity
cosdist:(')[1f-;cossim]                  / cosine distance

/ using the (d)istance (f)unction, cluster the data (X) into groups
/ defined by the closest (C)entroid
cgroup:{[df;X;C] group imin each flip df[X] each flip C}

/ k-(means|medians) algorithm

/ stuart lloyd's algorithm. using a (d)istance (f)unction and
/ (m)ean/edian (f)unction, find (k)-centroids in the data (X) starting
/ with a (C)entroid list. if C is an atom, use it to randomly
/ initialize C. if negative, use "Forgy" method and randomly pick k
/ centroids.  if positive, use "Random Partition" method to randomly
/ assign to k clusters.
lloyd:{[df;mf;X;C]
 if[0h>type C;if[0>C;C:X@\:C?count X 0]];
 g:$[0h>type C;group count[X 0]?C;cgroup[df;X;C]]; / assignment step
 C:mf''[X@\:value g];                              / update step
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
 dm[n]:imin each n#dm;        / find next closest element
 dm[n+1;where j=dm n+1]:i;    / all elements in cluster j are now in i
 dm:@[dm;n+2 3 4 5;,;(j;i;d;count where i=dm n+1)];
 dm}

/ given a (d)istance (f)unction and (l)inkage (f)unction, construct the
/ linkage (dendrogram) statistics of data in X
linkage:{[df;lf;X]
 dm:df[X] each flip X;                       / dissimilarity matrix
 dm:.[;;:;0w]/[dm;flip (i;i:til count X 0)]; / ignore loops
 dm,:enlist imin each dm;
 dm,:enlist til count dm 0;
 dm,:4#();
 l:-4#lw[lf] over dm;
 l}

/ merge node y[0] into y[1] in tree x
graft:{@[x;y;:;(::;x y)]}

/ build a complete dendrogram from linkage data x
tree:{1#(til[1+count x],(::)) graft/ x}

/ cut a single layer off tree
slice:{$[type x;x;type f:first x;(1_x),f;type ff:first f;(1_f),(1_x),ff;f,1_x]}

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
 p:exp -.5*sum X*inv[s2]$X-:mu;
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
em:{[lf;mf;X;pt]
 if[0h>type pt;pt:enlist pt#1f%pt]; / default to equal prior probabilities
 l:$[1<count pt;{(x . z) y}[lf;X] peach flip 1_pt;count[$[type X;X;X 0]]?/:count[pt 0]#1f];
 W:p%\:sum p:l*phi:pt 0;         / weights (responsibilities)
 if[0h<type phi;phi:avg each W]; / new prior probabilities (if phi is a list)
 theta:flip mf[X] peach W;       / new coefficients
 enlist[phi],theta}

/ return value which occur most frequently
mode:{imax count each group x}

/ k nearest neighbors

/ pick k closest values to x from training data X and return the
/ (c)lassification that occurs most frequently
knn:{[df;k;c;X;x]mode c k#iasc df[X;x]}

/ markov clusetering
/ if type of X is not a real or float, add loops and normalize
/ if (p)rune is an integer, take p largest, otherwise take everything > p
mcl:{[e;r;p;X]
 if[8h>type X 0;X%:sum each X|:diag count[X]#1b];
 X:xexp[(e-1)$[X]/X;r];
 X*:$[-8h<type p;(p>iasc idesc@)';p<]X;
 X%:sum each X;
 X}

/ naive bayes

/ fit parameters given (m)aximization (f)unction
/ returns a dictionary with prior and conditional likelihoods
fitnb:{[mf;w;X;y]count'[g],'{x[1_y;first y]}[mf] peach prepend[w;X]@\:/:g:group y}
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

odds:{x%sum x:count each x}
entropy:{neg sum x*2 xlog x}
eog:entropy odds group@
gain:{[n;x;y] / information gain (optionally (n)ormalized by splitinfo)
 g:eog[x]-sum (o:odds gy)*(not nk:null k:key gy)*eog each x gy:group y;
 if[n;g%:entropy o]; / gain ratio
 / TODO: distribute nulls down each branch with proportionate weight
 / if[count w:where nk;gy:(k[w]_gy),\:gy k first w];
 (g;::;gy)}

isnom:{type[x] in 1 2 4 10 11h} / is nominal

/ Improved use of continues attributes in c4.5 (quinlan) MDL
cgaina:{[gf;x;y] / continuous gain adapter
 if[isnom y;:gf[x;y]];          /TODO: handle null numbers
 g:(gain[0b;x] y >) each -1_u:asc distinct y; / use gain (not gf)
 g@:i:imax first each g;           / highest gain (not gain ratio)
 g[0]-:xlog[2;-1+count u]%count x; / MDL adjustment
 g[0]%:entropy odds g 2;           / convert to gain ratio
 g[1]:(avg u[i+0 1])<;             / split function
 g}

/ wilson score - binary confidence interval (Edwin Bidwell Wilson)
wscore:{[f;z;n]((f+z2n%2)+-1 1*z*sqrt((z2n%4)+f-f*f)%n)%1f+z2n:z*z%n}
/ pessimistic error
perr:{[z;x]last wscore[$[1=count g:group x;0;min count each g]%n;z;n:count x]}

/ given a (t)able of classifiers and labels where the first column is
/ target attribute create a decision tree using the (g)ain (f)unction.
/ pruning subtrees with minimum (n)umber of leaves and given confidence
/ pessimistic error
dt:{[gf;n;z;t]
 if[1=count d:flip t;:first d]; / no features to test
 if[all 1_(=':) a:first d;:a];  / all values are equal
 if[not n<count a;:a];          / don't split unless >n leaves
 if[all 0>=gr:first each g:gf[a] peach 1 _d;:a]; / compute gain (ratio)
 b:@[1_g ba;1;.z.s[gf;n;z] peach ((1#ba:imax gr)_t)@]; / classify subtree
 if[z>0;if[perr[z;a]>(count each last b) wavg perr[z] peach last b;:a]]; / prune
 (ba;b)}

/ decision tree classifier: classify the (d)ictionary based on
/ decision (t)ree
dtc:{[t;d]mode dtcr[t;d]}
dtcr:{[t;d]                              / recursive component
 if[type t;:t];                          / list of values
 if[null k:d t 0;:raze t[1;1] .z.s\: d]; / dig deeper for null values
 v:.z.s[t[1;1] t[1;0] k;d];              / split on next attribute
 v}

/ given a (t)able of classifiers and labels where the first column is
/ target attribute create a decision tree using the id3 algorithm
id3:dt[gain[0b];1;0]
q45:dt[cgaina[gain[1b]]] / like c4.5 (but does not train nulls or post-prune)

/ sparse matrix manipulation

dim:{$[n:count x;n,$[0h=type x;.z.s x 0;()];n]}
/ sparse from matrix
sparse:{(dim x;`p#where count each i;raze i;raze x@'i:where each not 0f=x)}
/ transpose
sflip:@[;0 2 1 3]
/ sparse matrix multiplication
smm:{enlist[(x[0;0];y[0;1])],value flip 0!select sum w*v by r,c from ej[`;flip ``c`v!1_y;flip`r``w!1_x]}
/ matrix from sparse
full:{./[x[0]#0f;flip x 1 2;:;x 3]}

/ given a (p)robability of random surfing and (A)djacency matrix
/ obtain the page rank by matrix inversion (inverse iteration)
pageranki:{[p;A]r%sum r:first enlist[r] lsq diag[r:n#1f]-((1f-p)%n:count A)+p*A%1f|sum each A}

/ given a (p)robability of random surfing, (A)djacency matrix and
/ (r)ank vector, multiply by the google matrix to obtain a better
/ ranking
pagerankr:{[p;A;r]((1f-p)%n)+p*((r%1f|d)$A)+(s:sum r where 0f=d:sum each A)%n:count A}

/ given a (p)robability of random surfing and (A)djacency matrix
/ create the markov Google matrix
google:{[p;A]((1f-p)%n)+p*(A%1|d)+(0=d:sum each A)%n:count A}

/ return a sorted dictionary of the ranked values
drank:{desc til[count x]!x}

/ top n svd factors
nsvd:{[n;usv]n#''@[usv;1;(n&:count usv 0)#]}

/ use svd decomposition to predict missing exposures for new (u)ser
/ (r)ecord OR (i)tem (r)ecord
foldin:{[usv;ur;ir]
 if[count ur;if[count ir;'`length]];
 if[count ur;usv[0],:ur$usv[2]$inv usv 1];
 if[count ir;usv[2],:flip ir$/:usv[0]$/:inv usv 1];
 usv}
