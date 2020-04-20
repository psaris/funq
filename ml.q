\d .ml

/ apply (f)unction (in parallel) to the 2nd dimension of (X) (flip if -g 0)
f2nd:{[f;X]$[system"g";(f value::) peach flip (count[X]#`)!X;f peach flip X]}

/ matrix primitives

mm:{$[;y] peach x}              / X  * Y
mmt:{(y$) peach x}              / X  * Y'
mtm:{f2nd[$[;y];x]}             / X' * Y
minv:inv                        / X**-1
mlsq:lsq                        / least squares
dot:$                           / dot product
diag:{$[0h>t:type x;x;@[n#t$0;;:;]'[til n:count x;x]]}
eye:{diag x#1f}
mdet:{[X]                       / determinant
 if[2>n:count X;:X];
 if[2=n;:(X[0;0]*X[1;1])-X[0;1]*X[1;0]];
 d:dot[X 0;(n#1 -1)*(.z.s (X _ 0)_\:) each til n];
 d}
mchol:{[X]                      / cholesky decomposition
 m:count X;
 L:(m;m)#0f;
 i:-1;
 while[m>i+:1;
  L[i;i]:sqrt X[i;i]-dot[L i;L i];
  j:i;
  while[m>j+:1;
   L[j;i]:(X[j;i]-dot[L i;L j])%L[i;i];
   ];
  ];
 L}

/ matrix overload of where
mwhere:{
 if[type x;:enlist where x];
 x:(,'/) til[count x] {((1;count y 0)#x),y}' .z.s each x;
 x}

/ returns true if all values are exactly equal
identical:{min first[x]~':x}

/ returns true if x is a matrix as defined by q
ismatrix:{
 if[type x;:0b];
 if[not all 9h=type each x;:0b];
 b:identical count each x;
 b}

/ basic utilities

imax:{x?max x}                  / index of max element
imin:{x?min x}                  / index of min element
/ (pre|ap)pend n rows of repeated x to matri(X)
pend:{[n;x;X]$[n>0;,[;X];X,](abs n;count X 0)#x}
prepend:pend[1]                 / prepend 1 row of repeated x to matri(X)
append:pend[-1]                 / append  1 row of repeated x to matri(X)
/ where not any null
wnan:{$[all type each x;where not any null x;::]}

/ norm primitives

mnorm:sum abs::                 / manhattan (taxicab) norm
/ euclidean norm squared
/ NOTE: wsum converts all types to float
enorm2:{$[9h=t:type x;dot[x;x];t or not system "g";x wsum x;f2nd[.z.s;x]]}
enorm:sqrt enorm2::             / euclidean norm
pnorm:{[p;x]sum[abs[x] xexp p] xexp 1f%p} / p norm

/ distance primitives

hdist:sum (<>)::                / hamming distance
mdist:mnorm (-)::               / manhattan (taxicab) distance
edist2:enorm2 (-)::             / euclidean distance squared
edist:enorm (-)::               / euclidean distance
pedist2:{enorm2[x]+/:enorm2[y]+-2f*mtm["f"$y;"f"$x]} / pairwise edist2
/pedist2:{enorm2[x]+/:enorm2[y]+-2f*f2nd[sum x*;y]} / pairwise edist2
mkdist:{[p;x;y]pnorm[p] x-y}                     / minkowski distance
hmean:1f%avg 1f%                                 / harmonic mean
cossim:{sum[x*y]%enorm[x i]*enorm y i:wnan(x;y)} / cosine similarity
cosdist:1f-cossim::                              / cosine distance
cordist:1f-(cor)::                               / correlation distance
/ spearman's rank (tied values get averaged rank)
srank:{@[x;g;:;avg each (x:"f"$rank x) g@:where 1<count each g:group x]}
/srank:{(avg each rank[x] group x) x}
scor:{srank[x i] cor srank y i:wnan(x;y)} / spearman's rank correlation
scordist:1f-scor::              / spearman's rank correlation distance

/ null-aware primitives (account for nulls in matrices)

ncount:{count[x]-$[type x;sum null x;0i {x+null y}/ x]}
nsum:{$[type x;sum x;0i {x+0i^y}/ x]}
navg:{$[type x;avg x;nsum[x]%ncount x]}
nwavg:{[w;x]$[type x;w wavg x;(%/){x+y*(0f^z;not null z)}/[0 0f;w;x]]}
nvar:{$[type x;var x;navg[x*x]-m*m:navg x]}
ndev:sqrt nvar::
nsvar:{$[type x;svar x;(n*nvar x)%-1+n:ncount x]}
nsdev:sqrt nsvar::

/ normalization primitives

/ apply (d)yadic function to the result of (a)ggregating
/ vector/matrix/dictionary/table x
dax:{[d;a;x]$[0h>type first x; d[x;a x]; d[;a x]peach x]}

/ normalize each vector to unit length
normalize:dax[%;enorm]
/ centered
demean:dax[-;navg]
/ feature normalization (centered/unit variance)
zscore:dax[%;nsdev] demean::
/ feature normalization (scale values to [0,1])
minmax:{(x-m)%max[x]-m:min x}
/ convert densities into probabilities
prb:dax[%;sum]

/ frequency and mode primitives

/ given a (w)eight atom or vector, and data x, return a sorted dictionary
/ mapping the distinct items to their weighted count
wfreq:{[w;x]@[x!count[x:asc distinct x]#0*first w;x;+;w]}
freq:wfreq[1]

/ given a (w)eight return (x)-value that occurs most frequently
wmode:imax wfreq::              / weighted mode
mode:wmode[1]                   / standard mode

/ weighted average or mode
isord:{type[x] in 0 8 9h}               / is ordered
aom:{$[isord x;avg;mode]x}              / average or mode
waom:{[w;x]$[isord x;nwavg;wmode][w;x]} / weighted average or mode

/ binary classification evaluation metrics (summary statistics)

/ given expected boolean values x and observed value y, compute
/ (tp;tn;fp;fn)
tptnfpfn:{tp,(("i"$count x)-tp+sum f),f:(sum x;sum y)-tp:sum x&y}

/ aka rand measure (William M. Rand 1971)
accuracy:{[tp;tn;fp;fn](tp+tn)%tp+tn+fp+fn}
precision:{[tp;tn;fp;fn]tp%tp+fp}
recall:{[tp;tn;fp;fn]tp%tp+fn}

/ f measure: given (b)eta and tp,tn,fp,fn compute the harmonic mean of
/ precision and recall
F:{[b;tp;tn;fp;fn]
 f:1+b2:b*b;
 f*:r:recall[tp;tn;fp;fn];
 f*:p:precision[tp;tn;fp;fn];
 f%:r+p*b2;
 f}
F1:F[1]

/ Fowlkes–Mallows index (E. B. Fowlkes & C. L. Mallows 1983)
/ geometric mean of precision and recall
FM:{[tp;tn;fp;fn]tp%sqrt(tp+fp)*tp+fn}

/ returns a number between 0 and 1 indicating the similarity of two datasets
jaccard:{[tp;tn;fp;fn]tp%tp+fp+fn}

/ Matthews Correlation Coefficient
/ correlation coefficient between the observed and predicted
/ -1 0 1 (none right, same as random prediction, all right)
MCC:{[tp;tn;fp;fn]((tp*tn)-fp*fn)%prd sqrt(tp;tp;tn;tn)+(fp;fn;fp;fn)}

/ k-fold cross validation primitives

/ use all data from ys and Xs except the (i)th element to fit a model using
/ the (f)itting (f)unction and then apply (p)rediction (f)unction on Xs[i]
kfxvyx:{[ff;pf;ys;Xs;i]     / k-fold cross validate vec y and matrix X
 X:(,'/)Xs _ i;             / drop i and raze
 y:raze ys _ i;             / drop i and raze
 m:ff[y;X];                 / fit model
 p:pf[m] Xs i;              / use model to make predictions:
 p}

/ use all data from (t)able(s) except the (i)th element to fit a model using
/ the (f)itting (f)unction and then use (p)rediction (f)unction on ts[i]
kfxvt:{[ff;pf;ts;i]             / k-fold cross validate table
 t:raze ts _ i;                 / drop i and raze
 m:ff[t];                       / fit model
 p:pf[m] ts i;                  / use model to make predictions
 p}

/ k nearest neighbors

/ find (k) smallest values from (d)istance vector (or matrix) and use
/ (w)eighting (f)unction to return the best estimate of y
knn:{[wf;k;y;d]
 if[not type d;:.z.s[wf;k;y] peach d];        / recurse for matrix d
 if[any n:null d;d@:i:where not n; y@:i];     / filter null distances
 k&:count y;                                  / prevent k > count y
 p:(waom . (wf d::;y)@\:#[;iasc d]::) each k; / make predictions
 p}

/ given (w)eighting (f)unction, (d)istance (f)unction, atom or vector of (k)
/ values, a (y) vector and matrix(X), return a prediction composition
fknn:{[wf;df;k;y;X] knn[wf;k;y] df[X]::}

/ partitional clustering initialization methods

/ generate (k) centroids by randomly choosing (k) samples from matri(X)
forgy:{[k;X]neg[k]?/:X}         / forgy method
/ generate (k) centroids by applying (c)entroid (f)unction to (k) random
/ partitions of matri(X)
rpart:{[cf;k;X](cf'') X@\:value group count[X 0]?k} / random partition
 
/ return the index of n (w)eighted samples
iwrand:{[n;w]s binr n?last s:sums w}
/ find n (w)eighted samples of x
wrand:{[n;w;x]x iwrand[n] w}

/ k-means++ initialization algorithm
/ using (d)istance (f)unction and matri(X), append the next centroid to the
/ min centroid (d)istance and all (C)entroids
kpp:{[df;X;d;C]
 if[not count C;:(0w;X@\:1?count X 0)]; / first centroid
 if[count[X 0]=n:count C 0;:(d;C)];     / no more centroids
 d&:df[X] C[;n-1];                      / update distance vector
 C:C,'X@\: first iwrand[1] d;           / pick next centroid
 (d;C)}
kmeanspp:kpp[edist2]            / k-means++ initialization
kmedianspp:kpp[mdist]           / k-medians++ initialization

/ partitional clustering algorithms

/ using the (d)istance (f)unction, group matri(X) based on the closest
/ (C)entroid and return the cluster indices
cgroup:{[df;X;C]value group f2nd[imin] f2nd[df X] C}

/ stuart lloyd's algorithm. uses (d)istance (f)unction to assign the
/ matrix(X) to the nearest (C)entroid and then uses the (c)entroid (f)unction
/ to update the centroid location.
lloyd:{[df;cf;X;C]cf X@\: cgroup[df;X;C]}

kmeans:lloyd[edist2;avg'']      / k-means
kmedians:lloyd[mdist;med'']     / k-medians
khmeans:lloyd[edist2;hmean'']   / k harmonic means
skmeans:lloyd[cosdist;normalize (avg'')::] / spherical k-means

/ using (d)istance (f)unction, find the medoid in matri(X)
medoid:{[df;X]X@\:imin f2nd[sum df[X]::] X}
/ given a (d)istance (f)unction, return a new function that finds a medoid
/ during the "update" step of lloyd's algorithm
pam:{[df]lloyd[df;flip f2nd[medoid df]::]} / partitioning around medoids

/ cluster purity primitives

/ given matri(X) compute the sum of squared errors (distortion)
sse:{[X]sum edist2[X] avg each X}
/ given matri(X) and cluster (I)ndices, compute within-cluster sse
ssw:{[X;I]sum (sse X@\:) peach I}
/ given matri(X) and cluster (I)ndices, compute between-cluster sse
ssb:{[X;I]count'[I] wsum edist2[(avg '')G] (avg raze::) each G:X@\:I}
/ using data matri(X) and (C)entroids, compute total cluster distortion
distortion:{[X;C]ssw[X] cgroup[edist2;X] C}

/ given (d)istance (f)unction, matri(X), and cluster (I)ndices, compute the
/ silhouette statistic. group I if not already grouped
silhouette:{[df;X;I]
 if[type I;s:.z.s[df;X]I:value group I;:raze[s] iasc raze I];
 if[1=n:count I;:count[I 0]#0f]; / special case a single cluster
 a:{[df;X](1f%-1+count X 0)*sum f2nd[df X] X}[df] peach G:X@\:/:I;
 b:{[df;G;i]min{f2nd[avg x[z]::]y}[df;G i]'[G _ i]}[df;G] peach til n;
 s:0f^(b-a)%a|b;                / 0 fill to handle single point clusters
 s}

/ hierarchical agglomerative clustering

/ lance-williams algorithm linkage functions. can be either a vector of four
/ floats or a function that accepts the cluster counts of i, j and list of
/ all cluster counts
lw.single:.5 .5 0 -.5
lw.complete:.5 .5 0 .5
lw.average:{(x%sum x _:2),0 0f}
lw.weighted:.5 .5 0 0
lw.centroid:{((x,neg prd[x]%s)%s:sum x _:2),0f}
lw.median:.5 .5 -.25 0
lw.ward:{((k+/:x 0 1),(neg k:x 2;0f))%\:sum x}

/ implementation of lance-williams algorithm for performing hierarchical
/ agglomerative clustering. given (l)inkage (f)unction to determine distance
/ between new and remaining clusters, (D)issimilarity matrix, and (I)ndex
/ list, return updated D and I
lancewilliams:{[lf;D;I]
 n:count D;
 d:D@'di:imin peach D;                          / find closest distances
 if[null d@:i:imin d;:(D;I)]; j:di i;           / find closest clusters
 c:$[9h=type lf;lf;lf(freq I 0)@/:(i;j;til n)]; / determine coefficients
 nd:sum c*nd,(d;abs(-/)nd:D (i;j));             / calc new distances
 D[;i]:D[i]:nd;                                 / update distances
 D[;j]:D[j]:n#0n;                               / erase j
 I[0;where j=I 0]:i;            / all elements in cluster j are now in i
 I[1 2],:(j;i);                 / append return values
 (D;I)}

/ given a (l)inkage (f)unction and (D)issimilarity matrix, run the
/ lance-williams linkage algorithm for hierarchical agglomerative clustering
/ and return the linkage stats: (from index j;to index i)
link:{[lf;D]
 D:@'[D;i:til count D;:;0n];                    / ignore loops
 if[-11h=type lf;lf:get lf];                    / dereference lf
 l:1_last .[lancewilliams lf] over (D;(i;();())); / obtain linkage stats
 l}

/ use (l)ink stats to create (k) clusters
clust:{[l;k]
 if[0h>type k;:first .z.s[l] k,()]; / special case atoms
 c:1 cut til 1+count l 0;           / initial clusters
 k@:i:idesc k;                      / sort k descending
 fl:(1-mk:last k)_ flip l;          / drop unwanted links
 fls:(0,-1_count[c]-k) cut fl;      / list of flipped link stats
 c:{[c;fl]{x[y 1],:x y 0;x[y 0]:();x}/[c;fl]}\[c;fls]; / link into k clusters
 c:c except\: enlist ();        / remove empty clusters
 c:c iasc i;                    / reorder based on original k
 c}

/ random variate primitives

pi:acos -1f
twopi:2f*pi
logtwopi:log twopi

/ box-muller
bm:{
 if[count[x] mod 2;:-1_.z.s x,rand 1f];
 x:raze (sqrt -2f*log first x)*/:(cos;sin)@\:twopi*last x:2 0N#x;
 x}

/ random number generators
/ generate (n) variates from a uniform distribution
runif:{[n]n?1f}
/ generate (n) variates from a bernoulli distribution with
/ (p)robability of success
rbern:{[n;p]p>runif n}
/ generate (n) variates from a binomial distribution (sum of
/ bernoulli) with (k) trials and (p)robability
rbinom:{[n;k;p]sum rbern[n] each k#p}
/ generate (n) variate-vectors from a multinomial distribution with
/ (k) trials and (p)robability vector defined for each class
rmultinom:{[n;k;p](sum til[count p]=/:sums[p] binr runif::) each n#k}
/ generate (n) variates from a normal distribution with mean (mu) and
/ standard deviation (sigma)
rnorm:{[n;mu;sigma]mu+sigma*bm runif n}

/ binomial pdf (not atomic because of factorial)
binpdf:{[n;p;k]
 if[0<max type each (n;p;k);:.z.s'[n;p;k]];
 r:prd[1+k+til n]%prd 1+til n-:k;
 r*:prd (p;1f-p) xexp (k;n);
 r}

/ binomial likelihood approximation (without the coefficient)
binl:{[n;p;k](p xexp k)*(1f-p) xexp n-k}
/ binomial log likelihood
binll:{[n;p;k](k*log p)+(n-k)*log 1f-p}
/binl:exp binll::
/ binomial maximum likelihood estimator
binmle:{[n;a;x]1#avg a+x%n}
wbinmle:{[n;a;w;x]1#w wavg a+x%n}

/ binomial mixture model likelihood
bmml:prd binl::
/ binomial mixture model log likelihood
bmmll:sum binll::
bmml:exp bmmll::             / more numerically stable
/ binomial mixture model maximum likelihood estimator (where a is
/ the dirichlet smoothing parameter)
bmmmle:{[n;a;w;x]enlist avg each a+x%n}
wbmmmle:{[n;a;w;x]enlist w wavg/: a+x%n}

/ multinomial log likelihood
multill:{[p;k]k*log p}
/ multinomial likelihood approximation
multil:{[p;k]p xexp k}
/ multinomial maximum likelihood estimator (where n is for add n smoothing)
multimle:{[n;x]enlist each x%sum x:n+sum each x}
wmultimle:{[n;w;x]enlist each x%sum x:n+w wsum/: x}

/ multinomial mixture model likelihood
mmml:prd multil::
/ multinomial mixture model log likelihood
mmmll:sum multill::
/mmml:exp mmmll::             / more numerically stable
/ multinomial mixture model maximum likelihood estimator (where a is
/ the dirichlet smoothing parameter)
mmmmle:{[n;a;w;x]enlist avg each a+x%n}
wmmmmle:{[n;a;w;x]enlist w wavg/: a+x%n}

/ gaussian kernel
gaussk:{[mu;sigma;x] exp (enorm2 x-mu)%-2*sigma}

/ gaussian likelihood
gaussl:{[mu;sigma;x]
 p:exp (x*x-:mu)%-2*sigma;
 p%:sqrt sigma*twopi;
 p}
/ guassian log likelihood
gaussll:{[mu;sigma;X] -.5*sum (logtwopi;log sigma;(X*X-:mu)%sigma)}
/ gaussian maximum likelihood estimator
gaussmle:{[x](mu;avg x*x-:mu:avg x)}
wgaussmle:{[w;x](mu;w wavg x*x-:mu:w wavg x)}

/ gaussian multivariate
gaussmvl:{[mu;SIGMA;X]
 if[type SIGMA;SIGMA:diag count[X]#SIGMA];
 p:exp -.5*sum X*mm[minv SIGMA;X-:mu];
 p*:sqrt 1f%mdet SIGMA;
 p*:twopi xexp -.5*count X;
 p}
/ gaussian multivariate log likelihood
gaussmvll:{[mu;SIGMA;X]
 if[type SIGMA;SIGMA:diag count[X]#SIGMA];
 p:sum X*mm[minv SIGMA;X-:mu];
 p+:log mdet SIGMA;
 p+:count[X]*logtwopi;
 p*:-.5;
 p}
/ gaussian multi variate maximum likelihood estimator
gaussmvmle:{[X](mu;avg X (*\:/:)' X:flip X-mu:avg each X)}
wgaussmvmle:{[w;X](mu;w wavg X (*\:/:)' X:flip X-mu:w wavg/: X)}


/ expectation maximization

likelihood:{[l;lf;X;phi;THETA]
 p:(@[;X]lf .) peach THETA;    / compute [log] probability densities
 p:$[l;p+log phi;p*phi];       / apply prior probabilities
 p}

/ using (l)ikelhood (f)unction, (w)eighted (m)aximum likelihood estimator
/ (f)unction with prior probabilities (p)hi and distribution parameters
/ (THETA) (with optional (f)itting of (p)hi) perform expectation maximization
em:{[fp;lf;wmf;X;phi;THETA]
 W:prb likelihood[0b;lf;X;phi;THETA]; / weights (responsibilities)
 if[fp;phi:avg each W];               / new phi estimates
 THETA:wmf[;X] peach W;               / new THETA estimates
 (phi;THETA)}

/ term frequency primitives

/ term document matrix built from (c)orpus and (v)ocabulary
tdm:{[c;v](-1_@[(1+count v)#0;;+;1]::) each v?c}

lntf:{log 1f+x}                    / log normalized term frequency
dntf:{[k;x]k+(1f-k)*x% max each x} / double normalized term frequenecy

idf: {log count[x]%sum 0<x}     / inverse document frequency
idfs:{log 1f+count[x]%sum 0<x}  / inverse document frequency smooth
idfm:{log 1f+max[x]%x:sum 0<x}  / inverse document frequency max
pidf:{log (max[x]-x)%x:sum 0<x} / probabilistic inverse document frequency
tfidf:{[tff;idff;x]tff[x]*\:idff x}

/ naive bayes

/ fit parameters given (w)eighted (m)aximization (f)unction returns a
/ dictionary with prior and conditional likelihoods
fnb:{[wmf;w;X;y]
 if[(::)~w;w:count[y]#1f];      / handle unassigned weight
 pT:(odds g; w[value g] wmf' X@\:/:g:group y);
 pT}

/ using a [log](l)ikelihood (f)unction and (cl)assi(f)ication perform naive
/ bayes prediction
pnb:{[l;lf;pT;X]
 d:{(x . z) y}[lf]'[X] peach pT[1]; / compute probability densities
 c:imax each flip $[l;log[pT 0]+sum flip d;pT[0]*prd flip d];
 c}

/ decision trees

/ odds & weighted odds
odds:{[g]prb count each g}
wodds:{[w;g]prb sum each w g}

/ classification impurity functions
misc:{1f-avg x=mode x}                  / misclassification
wmisc:{[w;x]1f-avg x=wmode[w;x]}        / weighted misclassification
gini:{1f-enorm2 odds group x}           / gini
wgini:{[w;x]1f-enorm2 wodds[w] group x} / weighted gini
entropy:{neg sum x*log x:odds group x}  / entropy
wentropy:{[w;x]neg sum x*log x:wodds[w] group x} / weighted entropy

/ regression impurity functions
mse:{enorm2[x-avg x]%count x}          / mean squared error
wmse:{[w;x]enorm2[x-w wavg x]%count x} / weighted mean squared error
mae:{avg abs x-avg x}                  / mean absolute error
wmae:{[w;x]avg abs x-w wavg x}         / weighted mean absolute error

rms:{sqrt avg x*x}              / root mean square error

/ create all combinations of length x from a list (or size of) y
cmb:{
 if[not 0>type y;:y .z.s[x] count y];
 if[null x;:raze .z.s[;y] each 1+til y];
 c:flip enlist flip enlist til y-:x-:1;
 c:raze c {(x+z){raze x,''y}'x#\:y}[1+til y]/til x;
 c}

/ use (i)m(p)urity (f)unction to compute the (w)eighted information gain of x
/ after splitting on y
ig:{[ipf;w;x;y]                 / information gain
 g:ipf[w] x;
 g-:sum wodds[w;gy]*(not null key gy)*w[gy] ipf' x gy:group y;
 (g;::;gy)}

/ use (i)m(p)urity (f)unction to compute the (w)eighted gain ratio of x after
/ splitting on y
gr:{[ipf;w;x;y]                 / gain ratio
 g:ig[ipf;w;x;y];
 g:@[g;0;%[;ipf[w;y]]];         / divide by splitinfo
 g}

/ use (i)m(p)urity (f)unction to pick the maximum (w)eighted information gain
/ of x after splitting across all sets of distinct y
sig:{[ipf;w;x;y]                / set information gain
 c:raze cmb[;u] each 1|count[u:distinct y] div 2;
 g:(ig[ipf;w;x] y in) peach c;
 g@:i:imax g[;0];               / highest gain
 g[1]:in[;c i];                 / replace split function
 g}

/ use (i)m(p)urity (f)unction to pick the maximum (w)eighted information gain
/ of x after splitting across all values of y
oig:{[ipf;w;x;y]                / ordered information gain
 g:(ig[ipf;w;x] y >) peach u:asc distinct y;
 g@:i:imax g[;0];               / highest gain (not gain ratio)
 g[1]:>[;avg u i+0 1];          / split function
 g}

/ use (i)m(p)urity (f)unction to pick the maximum (w)eighted gain ratio of x
/ after splitting across all values of y
ogr:{[ipf;w;x;y]                / ordered gain ratio
 g:oig[ipf;w;x;y];
 g:@[g;0;%[;ipf[w;g[1] y]]];    / divide by splitinfo
 g}

/ given a vector of (w)eights (or ::) and a (t)able of features where the
/ first column is the target attribute, create a decision tree using the
/ (c)ategorical (g)ain (f)unction and (o)rdered (g)ain (f)unction. the
/ (i)m(p)urity (f)unction determines which statistic to minimize. a dict of
/ (opt)ions specify the (max) (d)epth, (min)imum # of (s)amples required to
/ (s)plit, (min)imum # of samples at each leaf, (min)imum (g)ain and the
/ (max)imum (f)eature (f)unction used to sub sample features for random
/ forests.  defaults are: opt:`maxd`minss`minsl`ming`maxff!(0N;2;1;0;::)
dt:{[cgf;ogf;ipf;opt;w;t]
 if[(::)~w;w:n#1f%n:count t];       / compute default weight vector
 if[1=count d:flip t;:(w;first d)]; / no features to test
 opt:(`maxd`minss`minsl`ming`maxff!(0N;2;1;0;::)),opt; / default options
 if[0=opt`maxd;:(w;first d)];    / check if we've reached max depth
 if[identical a:first d;:(w;a)]; / check if all values are equal
 if[opt[`minss]>count a;:(w;a)]; / check if insufficent samples
 d:((neg floor opt[`maxff] count d)?key d)#d:1 _d;   / sub-select features
 d:{.[x isord z;y] z}[(cgf;ogf);(ipf;w;a)] peach d;  / compute gains
 d:(where (any opt[`minsl]>count each last::) each d) _ d; / filter on minsl
 if[0=count d;:(w;a)];          / check if all leaves have < minsl samples
 if[opt[`ming]>=first b:d bf:imax d[;0];:(w;a)]; / check gain of best feature
 c:count k:key g:last b;        / grab subtrees, feature names and count
 / distribute nulls down each branch with reduced weight
 if[c>ni:null[k]?1b;w:@[w;n:g nk:k ni;%;c-1];g:(nk _g),\:n];
 if[(::)~b 1;t:(1#bf)_t];       / don't reuse exhausted features
 b[2]:.z.s[cgf;ogf;ipf;@[opt;`maxd;-;1]]'[w g;t g]; / split sub-trees
 bf,1_b}

/ classify the (d)ictionary based on decision (tr)ee
dtc:{[tr;d] waom . dtcr[tr;d]}  / decision tree classifier
dtcr:{[tr;d]                    / recursive component
 if[2=count tr;:tr];            / (w;a)
 if[not null k:d tr 0;if[(a:tr[1][k]) in key tr[2];:.z.s[tr[2] a;d]]];
 v:(,'/) tr[2] .z.s\: d;    / dig deeper for null values
 v}

/ decistion tree pruning primitives

/ wilson score - binary confidence interval (Edwin Bidwell Wilson)
wscore:{[z;f;n](f+(.5*z2n)+-1 1f*z*sqrt((.25*z2n)+f-f*f)%n)%1f+z2n:z*z%n}
/ pessimistic error
perr:{[z;w;x]last wscore[z;wmisc[w;x];count x]}

/ use (e)rror (f)unction to post-prune (tr)ee
prune:{[ef;tr]
 if[2=count tr;:tr];               / (w;a)
 b:value tr[2]:.z.s[ef] each tr 2; / prune subtree
 if[any 3=count each b;:tr];       / can't prune
 e:ef . wa:(,'/) b;            / pruned error
 if[e<((sum first::) each b) wavg (ef .) each b;:wa];
 tr}

/ return the leaves of (tr)ee
leaves:{[tr]$[2=count tr;enlist tr;raze .z.s each last tr]}

/ using (e)rror (f)unction, return the decision (tr)ee's risk R(T) and number
/ of terminal nodes |T|
dtriskn:{[ef;tr](sum'[l[;0]] wsum ef ./: l;count l:leaves tr)}

/ using (e)rror (f)unction and regularization coefficient a, compute cost
/ complexity for (tr)ee
dtcc:{[ef;a;tr](1f;a) wsum dtriskn[ef;tr]}

/ given a decision (tr)ee, return all the subtrees sharing the same root
subtrees:{[tr]
 if[2=count tr;:enlist tr];
 str:tr 2; / subtree
 if[all l:2=count each str;:enlist (,'/) str]; / prune
 strs:(@[str;;:;].) each raze flip each flip (i;.z.s each str i:where not l);
 trs:@[tr;2;:;] each strs;
 trs,:enlist (,'/) leaves tr; / collapse this node too
 trs}

/ given an (i)m(p)urity function and the pair of values (a;tr), return the
/ minimum (a)lpha and its associated sub(tr)ee.
dtmina:{[ipf;atr]
 if[2=count tr:last atr;:atr];
 en:dtriskn[ipf;tr];
 ens:dtriskn[ipf] peach trs:subtrees tr;
 a:neg (%) . en - flip ens;
 atr:(a;trs)@\:i imin a i:idesc ens[;1]; / sort descending # nodes
 atr}

/ given an (e)rror function, a cost parameter (a)lpha and decision (tr)ee,
/ return the subtree that minimizes the cost complexity
dtmincc:{[ef;tr;a]
 if[2=count tr;:tr];
 strs:subtrees tr;
 strs@:iasc (count leaves::) each strs; / prefer smaller trees
 str:strs imin dtcc[ef;a] each strs;
 str}

/ k-fold cross validate (i)th table in (t)able(s) using (d)ecision (t)ree
/ (f)unction, (a)lphas and misclassification (e)rror (f)unction
dtkfxv:{[dtf;ef;a;ts]kfxvt[dtmincc[ef]\[;a]dtf::;dtc\:/:;ts]}

/ decision tree utilities

/ print leaf: prediction followd by classification error% or regresssion sse
pleaf:{[w;x]
 v:waom[w;x];                   / value
 e:$[isord x;string sum e*e:v-x;string[.1*"i"$1e3*1f-avg x = v],"%"];
 s:string[v], " (n = ", string[count x],", err = ",e, ")";
 s}

/ print (tr)ee with i(n)dent
ptree:{[n;tr]
 if[not n;:(pleaf . first xs),last xs:.z.s[n+1;tr]];
 if[2=count tr;:(tr;"")];
 s:1#"\n";
 s,:raze[(n)#enlist "|  "],raze string[tr 0 1],\:" ";
 s:s,/:string k:asc key tr 2;
 c:.z.s[n+1] each tr[2]k;        / child
 x:first each c;
 s:s,'": ",/:(pleaf .) each x;
 s:raze s,'last each c;
 x:(,'/) x;
 (x;s)}

/ print a single node for graphviz
pnode:{[p;l;tr]
 s:string[i:I+:1], " [label=\""; / 'I' shared across leaves
 c:$[b:2=count tr;enlist (tr;());.z.s'[i;key tr 2;value tr 2]];
 x:(,'/) first each c;
 s,:pleaf . x;
 if[not b;s,:"\\n",raze string[tr 0 1],\: " "];
 s:enlist s,"\"] ;";
 if[i>0;s,:enlist string[p]," -> ",string[i]," [label=\"",string[l],"\"] ;"];
 s,:raze last each c;
 (x;s)}

/ print graph text for use with the 'dot' graphviz command, graph-easy or
/ http://webgraphviz.com
pgraph:{[tr]
 s:enlist "digraph Tree {";
 s,:enlist "node [shape=box] ;";
 s,:last pnode[I::-1;`;tr]; / reset global variable used by pnode
 s,:1#"}";
 s}

/ decision tree projections

/ given a (t)able of classifiers and labels where the first column is target
/ attribute, create a decision tree
aid:dt[sig;oig;wmse]            / automatic interaction detection
thaid:dt[sig;oig;wmisc]         / theta automatic interaction detection
id3:dt[ig;ig;wentropy]          / iterative dichotomizer 3
q45:dt[gr;ogr;wentropy]         / like c4.5
ct:dt[oig;oig;wgini]            / classification tree
rt:dt[oig;oig;wmse]             / regression tree

/ random forest

/ generate (n) decision trees by applying (f) to a resampled (with
/ replacemnt) (t)able
bag:{[n;f;t](f ?[;t]::) peach n#count t} / Bootstrap Aggregating

/ given an atom or list (k), and Bootstrap Aggregating (m)odel, make
/ predictions on samples in (t)able
pbag:{[k;m;t]
 if[count[m]<max k;'`length];
 p:k {(aom x#) each y}\: m dtc\:/: t;
 p}

/ discrete adaptive boosting

/ given (t)rain (f)unction, discrete (c)lassifier (f)unction, (t)able, and
/ initial (w)eights, return ((m)odel;(a)lpha;new (w)eights)
adaboost:{[tf;cf;t;w]
 if[(::)~w;w:n#1f%n:count t];    / initialize weights
 m:tf[w] t;                      / train model
 p:cf[m] each t;                 / make predictions
 e:sum w*not c:p=y:first flip t; / compute weighted error
 a:.5*log (c:1f-e)%e;            / compute alpha (minimize exponential loss)
 / w*:exp neg a*y*p;               / increase/decrease weights
 / w%:sum w;                       / normalize weights
 w%:2f*?[y=p;c;e];               / increase/decrease and normalize weights
 (m;a;w)}

/ given an atom or list (k), (t)rain (f)unction, discrete (c)lassifier
/ (f)unction, and (t)able perform max(k) iterations of adaboost
fab:{[k;tf;cf;t] 1_max[k] (adaboost[tf;cf;t] last::)\ (::)}

/ given an atom or list (k), discrete (c)lassifier function, adaboost
/ (m)odel, make predictions on samples in (t)able
pab:{[k;cf;m;t]
 if[count[m]<mx:max k;'`length];
 p:m[;1] * m[;0] cf/:\: t;
 p:signum $[0h>type k;sum k#p;sums[mx#p] k-1];
 p}

/ regularization primitives

/ reverse of over (start deep and end shallow)
revo:{[f;x]$[type x;f x;type first x;f f peach x;f .z.s[f] peach x]}

/ given l1 regularization (l)ambda and size of dimension (m), return two
/ function compositions that compute the cost and gradient
l1:{[l;m]((l%m)*revo[sum] abs::;(l%m)*signum::)}

/ given l2 regularization (l)ambda and size of dimension (m), return two
/ function compositions that compute the cost and gradient
l2:{[l;m]((.5*l%m)*revo[sum] {x*x}::;(l%m)*)}

/ given (a)lpha and (l)ambda (r)atio elastic net parameters, convert them
/ into l1 and l2 units and return a pair of l1 and l2 projections
enet:{[a;lr](l1 a*lr;l2 a*1f-lr)}

/ gradient descent utilities

/ accumulate cost by calling (c)ost (f)unction on the result of applying
/ (m)inimization (f)unction to THETA.  return (THETA;new cost vector)
acccost:{[cf;mf;THETA;c] (THETA;c,cf THETA:mf THETA)}

/ print number of iterations, current (c)ost and pct decrease, then return a
/ continuation boolean: pct decrease > float (p) or iterations > integer (p)
continue:{[h;p;c]
 pct:$[2>n:count c;0w;1f-(%/)c n-1 2];
 b:$[-8h<type p;p>n;p<pct];
 s:" | " sv ("iter: ";"cost: ";"pct: ") ,' string (n;last c;pct);
 if[not null h; h s,"\n\r" b];
 b}

/ keep calling (m)inimization (f)unction on (THETA) until the pct decrease in
/ the (c)ost (f)unction is less than (p). return (cost vector;THETA)
iter:{[h;p;cf;mf;THETA](continue[h;p]last::)acccost[cf;mf]//(::;cf)@\:THETA}

/ (a)lpha: learning rate, gf: gradient function
gd:{[a;gf;THETA] THETA-a*gf THETA} / gradient descent

/ optimize (THETA) by using gradient descent with learning rate (a) and
/ (g)radient (f)unction over (n) subsamples of (X) and (Y) generated with
/ (s)ampling (f)unction: til = no shuffle, 0N? = shuffle, {x?x} = bootstrap
sgd:{[a;gf;sf;n;Y;X;THETA]        / stochastic gradient descent
 i:(n;0N)#sf count X 0;
 THETA:THETA (gd[a] . (gf .;::)@'{(x[;;z];y)}[(Y;X)]::)/ i;
 THETA}

/ linear regression

/ given target matrix Y and data matri(X), return the THETA matrix resulting
/ from minimizing sum of squared residuals
normeq:{[Y;X]mm[mmt[Y;X]] minv mmt[X;X]} / normal equations ols

/ given (l2) regularization parameter, target matrix Y and data matri(X),
/ return the THETA matrix resulting from performing ridge regression
ridge:{[l2;Y;X]mm[mmt[Y;X]] minv mmt[X;X]+diag count[X]#l2}

/ given (l2) regularization parameter, target vector y and data matri(X),
/ return the theta vector resulting from performing weighted ridge regression
/ by scaling the regularization parameter by the count of non-null values
wridge:{[l2;X;y]first ridge[l2*count i;enlist y i;X[;i:where not null y]]}

/ linear predict Y values by prepending matri(X) with a vector of 1s
/ and multiplying the result to (THETA) coefficients
linpredict:{[X;THETA]mm[THETA] prepend[1f] X}

/ linear regression cost
lincost:{[rf;Y;X;THETA]
 J:(.5%m:count X 0)*sum (sum') E*E:0f^linpredict[X;THETA]-Y;
 if[count rf,:();THETA[;0]:0f; J+:sum rf[;m][;0][;THETA]];
 J}

/ linear regression gradient
lingrad:{[rf;Y;X;THETA]
 G:(1f%m:count X 0)*mmt[0f^mm[THETA;X]-Y] X:prepend[1f] X;
 if[count rf,:();THETA[;0]:0f; G+:sum rf[;m][;1][;THETA]];
 G}

/ linear cost & gradient
lincostgrad:{[rf;Y;X;theta]
 THETA:(count Y;0N)#theta; X:prepend[1f] X;
 J:(.5%m:count X 0)*sum (sum') E*E:0f^mm[THETA;X]-Y;
 G:(1f%m)*mmt[E] X;
 if[count rf,:();THETA[;0]:0f;JG:rf[;m][;;THETA];J+:sum JG@'0;G+:sum JG@'1];
 (J;raze G)}

/ activation primitives (derivatives optionally accept `z`a!(z;a) dict)

linear:(::)                                   / linear
dlinear:{1f+0f*$[99h=type x;x`z;x]}           / linear gradient
sigmoid:1f%1f+exp neg::                       / sigmoid
dsigmoid:{x*1f-x:$[99h=type x;x`a;sigmoid x]} / sigmoid gradient
tanh:{(a-b)%(a:exp x)+b:exp neg x}            / hyperbolic tangent
dtanh:{1f-x*x:$[99h=type x;x`a;tanh x]}       / hyperbolic tangent gradient
relu:0f|                              / rectified linear unit
drelu:{"f"$0f<=$[99h=type x;x`z;x]}   / rectified linear unit gradient
lrelu:{x*1 .01@0f>x}                  / leaky rectified linear unit
dlrelu:{1 .01@0f>$[99h=type x;x`z;x]} / leaky rectified linear unit gradient

softmax:prb exp::               / softmax
ssoftmax:softmax dax[-;max]::   / stable softmax
dsoftmax:{diag[x] - x*\:/:x:softmax x} / softmax gradient

/ loss primitives

/ given true (y) and (p)redicted values return the log loss
logloss:{[y;p]neg (y*log 1e-15|p)+(1f-y)*log 1e-15|1f-p}
/ given true (y) and (p)redicted values return the cross entropy loss
celoss:{[y;p]neg sum y*log 1e-15|p}
/ given true (y) and (p)redicted values return the mean squared error loss
mseloss:{[y;p].5*y*y-:p}

/ logistic regression

/ logistic regression predict
logpredict:sigmoid linpredict::

/ logistic regression cost
logcost:{[rf;Y;X;THETA]
 J:(1f%m:count X 0)*sum (sum') logloss[Y] logpredict[X;THETA];
 if[count rf,:();THETA[;0]:0f; J+:sum rf[;m][;0][;THETA]];
 J}

/ logistic regression gradient
loggrad:{[rf;Y;X;THETA]
 G:(1f%m:count X 0)*mmt[sigmoid[mm[THETA;X]]-Y] X:prepend[1f] X;
 if[count rf,:();THETA[;0]:0f; G+:sum rf[;m][;1][;THETA]];
 G}

logcostgrad:{[rf;Y;X;theta]
 THETA:(count Y;0N)#theta; X:prepend[1f] X;
 J:(1f%m:count X 0)*sum (sum') logloss[Y] P:sigmoid mm[THETA] X;
 G:(1f%m)*mmt[P-Y] X;
 if[count rf,:();THETA[;0]:0f;JG:rf[;m][;;THETA];J+:sum JG@'0;G+:sum JG@'1];
 (J;raze G)}

logcostgradf:{[rf;Y;X]
 Jf:logcost[rf;Y;X]enlist::;
 Gf:loggrad[rf;Y;X]enlist::;
 (Jf;Gf)}

/ one vs all

/ given binary classification fitting (f)unction, fit a one-vs-all model
/ against Y for each unique (lbls)
fova:{[f;Y;lbls] (f "f"$Y=) peach lbls}

/ given data matri(X) and (THETA) coefficients, return integer of THETA
/ vector that produces highest one-vs-all value (probability)
pova:{[Y]f2nd[imax] Y}

/ neural network matrix initialization primitives

/ Xavier Glorot and Yoshua Bengio (2010) initialization
/ given the number of (i)nput and (o)utput nodes, initialize THETA matrix
glorotu:{[i;o]sqrt[6f%i+o]*-1f+i?/:o#2f}  / uniform
glorotn:{[i;o]rnorm'[o#i;0f;sqrt 2f%i+o]} / normal

/ Kaiming He, Xiangyu Zhang, Shaoqing Ren, Jian Sun (2015) initialization
/ given the number of (i)nput and (o)utput nodes, initialize THETA matrix
heu:{[i;o]sqrt[6f%i]*-1f+i?/:o#2f}   / uniform
hen:{[i;o]rnorm'[o#i;0f;sqrt 2f%i]}  / normal

/ neural network primitives

/ use (h)idden and (o)utput layer functions to predict neural network Y
nnpredict:{[hof;X;THETA]
 X:X (hof[`h] linpredict::)/ -1_THETA;
 Y:hof[`o] linpredict[X] last THETA;
 Y}

/ (r)egularization (f)unction, holf: (h)idden (o)utput (l)oss functions
nncost:{[rf;holf;Y;X;THETA]
 J:(1f%m:count X 0)*sum (sum') holf[`l][Y] nnpredict[holf;X] THETA;
 if[count rf,:();THETA[;;0]:0f;J+:sum rf[;m][;0][;THETA]];
 J}

/ (r)egularization (f)unction, hgof: (h)idden (g)radient (o)utput functions
nngrad:{[rf;hgof;Y;X;THETA]
 ZA:enlist[(X;X)],(X;X) {(z;x z:linpredict[y 1;z])}[hgof`h]\ -1_THETA;
 P:hgof[`o] linpredict[last[ZA]1;last THETA]; / final layer
 G:hgof[`g]@'`z`a!/:1_ZA;                     / activation gradients
 D:reverse{[D;THETA;G]G*1_mtm[THETA;D]}\[E:P-Y;reverse 1_THETA;reverse G];
 G:(1%m:count X 0)*(D,enlist E) mmt' prepend[1f] each ZA[;1]; / full gradient
 if[count rf,:();THETA[;;0]:0f; G+:sum rf[;m][;1][;THETA]];
 G}

/ neural network cut
nncut:{[n;x]n cut' sums[prev[n+:1]*n:-1_n] cut x}

/ (r)egularization (f)unction, (n)etwork topology dimensions, hgolf: (h)idden
/ (g)radient (o)utput (l)oss functions
nncostgrad:{[rf;n;hgolf;Y;X;theta]
 THETA:nncut[n] theta;
 ZA:enlist[(X;X)],(X;X) {(z;x z:linpredict[y 1;z])}[hgolf`h]\ -1_THETA;
 P:hgolf[`o] linpredict[last[ZA]1;last THETA];    / final layer
 J:(1f%m:count X 0)*sum (sum') hgolf[`l][Y;P];    / cost
 G:hgolf[`g]@'`z`a!/:1_ZA;                        / activation gradients
 D:reverse{[D;THETA;G]G*1_mtm[THETA;D]}\[E:P-Y;reverse 1_THETA;reverse G];
 G:(1f%m)*(D,enlist E) mmt' prepend[1f] each ZA[;1]; / full gradient
 if[count rf,:();THETA[;;0]:0f;JG:rf[;m][;;THETA];J+:sum JG@'0;G+:sum JG@'1];
 (J;2 raze/ G)}

/ collaborative filtering

/ collaborative filtering predict
cfpredict:{[X;THETA] mtm[THETA;X]}

/ collaborative filtering cost
cfcost:{[rf;Y;X;THETA]
 J:(.5f%m:count X 0)*sum (sum') E*E:cfpredict[X;THETA]-Y;
 if[count rf,:();J+:sum rf[;m][;0]@\:(X;THETA)];
 J}

/ collaborative filtering gradient
cfgrad:{[rf;Y;X;THETA]
 G:(1f%m:count X 0)*(mm[THETA;E];mmt[X] E:0f^cfpredict[X;THETA]-Y);
 if[count rf,:();G+:sum rf[;m][;1]@\:(X;THETA)];
 G}

/ collaborative filtering cut where n:(ni;nu)
cfcut:{[n;x]n cut'(0,n[0]*count[x]div sum n) cut x}

/ collaborative filtering cost & gradient
cfcostgrad:{[rf;n;Y;xtheta]
 THETA:last X:cfcut[n] xtheta;X@:0;
 J:(.5%m:count X 0)*sum (sum') E*E:0f^cfpredict[X;THETA]-Y;
 G:(1f%m)*(mm[THETA;E];mmt[X;E]);
 if[count rf,:();JG:rf[;m][;;(X;THETA)];J+:sum JG@'0;G+:sum JG@'1];
 (J;2 raze/ G)}

/ using learning rate (a)lpha, and (l2) regularization parameter, factorize
/ matrix Y using stochastic gradient descent by solving for each non null
/ value one at a time.  (s)ampling (f)unction: til = no shuffle, 0N? =
/ shuffle, {x?x} = bootstrap.  pass (::) for xy to initiate sgd.
sgdmf:{[a;l2;sf;Y;XTHETA;xy] / sgd matrix factorization
 if[(::)~xy;:XTHETA .z.s[a;l2;sf;Y]/ i sf count i:flip mwhere not null Y];
 e:(Y . xy)-dot . xt:XTHETA .'i:flip(::;xy 1 0);
 XTHETA:./[XTHETA;0 1,'i;+;a*(e*xt 1 0)-l2*xt];
 XTHETA}

/ ALS-WR (a)lternating (l)east (s)quares with (w)eighted (r)egularization
alswr:{[l2;Y;XTHETA]
 X:flip f2nd[wridge[l2;XTHETA 1]] Y; / hold THETA constant, solve for X
 THETA:flip wridge[l2;X] peach Y;    / hold X constant, solve for THETA
 (X;THETA)}

/ top n svd factors
nsvd:{[n;usv]n#''@[usv;1;(n:min n,count each usv 0 2)#]}

/ use svd decomposition to predict missing exposures for new user
/ (ui=0b) or item (ui=1b) (r)ecord
foldin:{[usv;ui;r]@[usv;0 2 ui;,;mm[enlist r] mm[usv 2 0 ui] minv usv 1]}

/ gradient checking primitives

/ compute numerical gradient of (f)unction evaluated at x using steps of size
/ (e)psilon. compute partial derivatives if (e)psilon is a list
numgrad:{[f;x;e](.5%e)*{x[y+z]-x[y-z]}[f;x] peach diag e}

/ return analytic gradient using (g)radient (f)unction and numerical gradient
/ by evaluating (c)ost (f)unction on theta perturbed by (e)psilon
checkgrad:{[e;cf;gf;theta]
 ag:gf theta;                         / analytic gradient
 ng:numgrad[cf;theta] count[theta]#e; / numerical gradient
 (ag;ng)}

/ hgolf: (h)idden (g)radient (o)utput (l)oss functions
checknngrad:{[e;rf;n;hgolf]
 theta:2 raze/ glorotu'[1+-1_n;1_n];
 X:glorotu[n 1;n 0];
 y:1+(1+til n 1) mod last n;
 Y:flip eye[last n]"i"$y-1;
 cgf:nncostgrad[rf;n;hgolf;Y;X]; / cost gradient function
 r:checkgrad[e;first cgf::;last cgf::;theta];
 r}

checkcfgrad:{[e;rf;n]
 ni:n 0;nu:n 1 ;nf:10;          / n items, n users, n features
 Y:mm[nf?/:nu#1f]ni?/:nf#1f;    / random recommendations
 Y*:0N 1@.5<ni?/:nu#1f;         / drop some recommendations
 xtheta:2 raze/ (X:ni?/:nf#1f;THETA:nu?/:nf#1f); / random initial parameters
 cgf:cfcostgrad[rf;n;Y];                     / cost gradient function
 r:checkgrad[e;first cgf::;last cgf::;xtheta];
 r}

/ sparse matrix manipulation

/ shape of a tensor (atom, vector, matrix, etc)
shape:{$[0h>t:type x;();n:count x;n,.z.s x 0;1#0]}
/ rank of a tensor (atom, vector, matrix, etc)
dim:count shape::
/ sparse from matrix
sparse:{enlist[shape x],i,enlist (x') . i:mwhere "b"$x}
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

/ google pagerank

/ given a (d)amping factor (1 - the probability of random surfing) and the
/ (A)djacency matrix, create the markov Google matrix
google:{[d;A]
 M:A%1f|s:sum each A;           / convert to markov matrix
 M+:(0f=s)%n:count M;           / add links to dangling pages
 M:(d*M)+(1f-d)%n;              / dampen
 M}

/ given a (d)amping factor (1 - the probability of random surfing) and the
/ (A)djacency matrix, obtain the pagerank algebraically
pageranka:{[d;A]
 M:A%1f|s:sum each A;           / convert to markov matrix
 M+:(0f=s)%n:count M;           / add links to dangling pages
 r:prb first mlsq[(1;n)#(1f-d)%n] eye[n]-d*M; / compute rankings
 r}

/ given a (d)amping factor (1 - the probability of random surfing), the
/ (A)djacency matrix and an initial (r)ank vector, obtain a better ranking
/ (iterative model)
pageranki:{[d;A;r]
 w:sum r*0f=s:sum each A;       / compute dangling weight
 r:sum[A*r%1f|s]+w%n:count A;   / compute rankings
 r:(d*r)+(1f-d)%n;              / dampen
 r}

/ given a (d)amping factor (1 - the probability of random surfing), the
/ (S)parse adjacency matrix and an initial (r)ank vector, obtain a better
/ ranking (iterative model)
pageranks:{[d;S;r]
 w:sum r*0f=s:0f^sum'[S[3] group S 1]til n:S[0;0]; / compute dangling weight
 r:first full[smm[sparse enlist r%1f|s;S]]+w%n;    / compute rankings
 r:(d*r)+(1f-d)%n;                                 / dampen
 r}

/ dimensionality reduction

covm:{[X] mmt[X;X]%count X 0}     / covariance matrix
pca:{[X] last .qml.mev covm X}    / eigen vectors of scatter matrix
project:{[V;X] mtm[V] mm[V;X]}    / project X onto subspace V

/ markov clustering

addloop:{x|diag max peach x|flip x}

expand:{[e;X](e-1)mm[X]/X}

inflate:{[r;p;X]
 X:X xexp r;                              / inflate
 X*:$[-8h<type p;(p>iasc idesc::)';p<] X; / prune
 X%:sum peach X;                          / normalize
 X}

/ if (p)rune is an integer, take p largest, otherwise take everything > p
mcl:{[e;r;p;X] inflate[r;p] expand[e] X}

chaos:{max {max[x]-enorm2 x} peach x}
interpret:{1_asc distinct f2nd[where] 0<x}

/ complex primitives

cmul:{((-/)x*y;(+/)x*(|:)y)}    / complex multiplication
csqr:{((-/)x*x;2f*(*/)x)}       / complex square

/ mandelbrot

mbrotf:{[c;x]c+csqr x}                     / mandelbrot function
mbrotp:{not 4f<0w^enorm2 x}                / mandelbrot predicate
mbrota:{[c;x;n](x;n+mbrotp x:mbrotf[c;x])} / mandelbrot accumulator
