\d .ml

/ returns boolean indicating preference not to flip matrices
noflip:{system"g"}              / redefine to customize behavior

/ apply (f)unction (in parallel) to the 2nd dimension of (X)
f2nd:{[f;X]$[noflip[];(f value::) peach flip (count[X]#`)!X;f peach flip X]}

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
mchol:{[X]                      / Cholesky decomposition
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

/ tensor variant of where
twhere:{
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

/ find row indices of each atom/vec y in matrix/flipped table x
mfind:{{[x;i;j;y]?[y=x;i&j;i]}[y]/[count[first x]#n;til n:count x;x]}

/ return first index of atom/vec y in vec/dict/matrix/flipped table x
find:{$[0h>type first x;?;type x;key[x]mfind::;mfind][x;y]}
imax:{find[x;max x]}            / index of max element
imin:{find[x;min x]}            / index of min element

/ (pre|ap)pend n rows of repeated x to matri(X)
pend:{[n;x;X]$[n>0;,[;X];X,](abs n;count X 0)#x}
prepend:pend[1]                 / prepend 1 row of repeated x to matri(X)
append:pend[-1]                 / append  1 row of repeated x to matri(X)
/ where not any null
wnan:{$[all type each x;where not any null x;::]}

/ norm primitives

mnorm:sum abs::                           / Manhattan (taxicab) norm
enorm2:{x wsum x}                         / Euclidean norm squared
enorm:sqrt enorm2::                       / Euclidean norm
pnorm:{[p;x]sum[abs[x] xexp p] xexp 1f%p} / parameterized norm

/ distance primitives

hdist:sum (<>)::                / Hamming distance
mdist:mnorm (-)::               / Manhattan (taxicab) distance
edist2:enorm2 (-)::             / Euclidean distance squared
edist:enorm (-)::               / Euclidean distance
pedist2:{enorm2[x]+/:enorm2[y]+-2f*mtm["f"$y;"f"$x]} / pairwise edist2
mkdist:{[p;x;y]pnorm[p] x-y}                     / Minkowski distance
hmean:1f%avg 1f%                                 / harmonic mean
cossim:{sum[x*y]%enorm[x i]*enorm y i:wnan(x;y)} / cosine similarity
cosdist:1f-cossim::                              / cosine distance
cordist:1f-(cor)::                               / correlation distance
/ Spearman's rank (tied values get averaged rank)
srank:{@[x;g;:;avg each (x:"f"$rank x) g@:where 1<count each g:group x]}
scor:{srank[x i] cor srank y i:wnan(x;y)} / Spearman's rank correlation
scordist:1f-scor::              / Spearman's rank correlation distance

gower:{                                             / Gower distance
 if[0h=t:min abs type each (x;y);:navg .z.s'[x;y]]; / iterate
 if[1h=t;:not[all (x;y)]+0n 0 any (x;y)];           / asymmetric binary
 if[(t > 19h)|t in 2 10 11h;:"f"$not x=y];          / nominal
 d:abs[x-y]%(-) . (max;min) revo\: (x;y);           / ordinal and continuous
 d}

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

/ return a function that applies (d)yadic function to the result of
/ (a)ggregating vector/matrix/dictionary/table x
daxf:{[d;a;x]$[0h>type first x; d[;a x]; d[;a x] peach]}
/ apply (d)yadic function to the result of (a)ggregating
/ vector/matrix/dictionary/table x
dax:{[d;a;x]daxf[d;a;x] x}

/ apply the result of f[x] to x
fxx:{[f;x]f[x] x}

/ normalize each vector to unit length
normalize:dax[%;enorm]
/ centered
demean:fxx demeanf:daxf[-;navg]
/ feature normalization (centered/unit variance)
zscore:fxx zscoref:{daxf[%;nsdev;x] demeanf[x]::}
/ feature normalization (scale values to [0,1])
minmax:fxx minmaxf:{daxf[%;{max[x]-min x};x] daxf[-;min;x]::}
/ decimal precision (scale values to [0,1])
decprec:{x%10 xexp ceiling max 10 xlog abs x}
/ convert densities into probabilities
prb:dax[%;sum]
/ identify the minimum values with 1b
ismin:dax[=;min]

/ given (g)rouped dictionary, compute the odds
odds:{[g]prb count each g}
/ given (w)eight vector and (g)rouped dictionary, compute the weighted odds
wodds:{[w;g]prb sum each w g}

/ frequency and mode primitives

/ given a (w)eight atom or vector and data (x), return a dictionary (sorted
/ by key) mapping the distinct items to their weighted count
wfreq:{[w;x]@[x!count[x:asc distinct x]#0*first w;x;+;w]}
freq:wfreq[1]

/ given a (w)eight atom or vector and data (x), return x with maximum
/ weighted frequency
wmode:imax wfreq::              / weighted mode
mode:wmode[1]                   / standard mode

/ weighted average or mode
isord:{type[x] in 0 8 9h}               / is ordered
aom:{$[isord x;avg;mode]x}              / average or mode
waom:{[w;x]$[isord x;nwavg;wmode][w;x]} / weighted average or mode

/ binary classification evaluation metrics (summary statistics)

/ given actual values (y) and (p)redicted values, compute (tp;tn;fp;fn)
tptnfpfn:{[y;p]tp,(("i"$count y)-tp+sum f),f:(sum p;sum y)-/:tp:sum p&y}

/ aka Rand measure (William M. Rand 1971)
accuracy:{[tp;tn;fp;fn](tp+tn)%tp+tn+fp+fn}
precision:{[tp;tn;fp;fn]tp%tp+fp}
recall:sensitivity:hitrate:tpr:{[tp;tn;fp;fn]tp%tp+fn} / true positive rate
selectivity:specificity:tnr:{[tp;tn;fp;fn]tn%tn+fp}    / true negative rate
fallout:fpr:{[tp;tn;fp;fn]fp%fp+tn}                    / false positive rate
missrate:fnr:{[tp;tn;fp;fn]fn%fn+tp}                   / false negative rate
dice:{[tp;tn;fp;fn]tp%fp+fn+tp*:2}                     / dice coefficient

/ receiver operating characteristic
roc:{[y;p]
 r:(til[count s]-s;s:0f,sums y i:idesc p); / (fp;tp)
 r:(r%last each r),enlist 0w,p i;          / (fpr;tpr;threshold)
 r:r@\:where reverse differ reverse r 2;   / filter duplicate thresholds
 r}

auc:{[x;y] .5*sum (x-prev x)*y+prev y} / area under the curve

/ f measure: given (b)eta and tp,tn,fp,fn compute the harmonic mean of
/ precision and recall
f:{[b;tp;tn;fp;fn]
 f:1+b2:b*b;
 f*:r:recall[tp;tn;fp;fn];
 f*:p:precision[tp;tn;fp;fn];
 f%:r+p*b2;
 f}
f1:f[1]

/ Fowlkes–Mallows index (E. B. Fowlkes & C. L. Mallows 1983)
/ geometric mean of precision and recall
fmi:{[tp;tn;fp;fn]tp%sqrt(tp+fp)*tp+fn}

/ returns a number between 0 and 1 indicating the similarity of two datasets
jaccard:{[tp;tn;fp;fn]tp%tp+fp+fn}

/ Matthews correlation coefficient
/ correlation coefficient between the observed and predicted
/ -1 0 1 (none right, same as random prediction, all right)
mcc:{[tp;tn;fp;fn]((tp*tn)-fp*fn)%prd sqrt(tp;tp;tn;tn)+(fp;fn;fp;fn)}

/ regression evaluation metrics

/ given true (y) and (p)redicted values return the r^2
r2:{[y;p]1f-edist2[y;p]%edist2[y;avg y]}

/ given true labels y and predicted labels p, return a confusion matrix
cm:{[y;p]
 n:count u:asc distinct y,p;
 m:./[(n;n)#0;flip (u?p;u?y);1+];
 t:([]y:u)!flip (`$string u)!m;
 t}

/ given group (I)ndices, return list of (train;test) splits (where each split
/ is used for validation and the remaining k-1 folds are for training)
kfold:{[I]flip ((raze I _) each til count I;I)}
/ given group (I)ndices, return list of time-series (train;test) splits
/ (where each split is used for validation and the prior folds are for
/ training). (tr)ai(n) (f)unction and (t)e(st) (f)unction can be used to
/ customize the folds.
tsfold:{[trnf;tstf;I]
 trn:(trnf raze #[;I]::) each 1_til count I;
 tst:tstf each 1_I;
 flip (trn;tst)}

/ index vector or second dimension of matrix
at:{[x;i]$[type x;x i;x[;i]]}

/ use (train;test) (i)ndices to fit a model using the (f)itting (f)unction
/ with training subset of x. return predictions obtained from using the
/ (p)rediction (f)unction on the test subset. x can be a table or (y|Y;x|X)
/ pair -- corresponding to ff arguments.
cv:{[ff;pf;x;i]                           / cross validate
 if[not type i 0;:.z.s[ff;pf;x] peach i]; / iterate over folds
 tt:$[type x;x i;raze[x at\:/:i] _ 2];    / handle table vs (y|Y;x|X)
 m:ff . -1 _ tt;                          / fit model on train set
 p:pf[m] last tt;                         / make predictions
 p}

/ use all (f)old(s) (except the (i)th) to fit a model using the (f)itting
/ (f)unction and then use (p)rediction (f)unction on fs[i]. fs can be a list
/ of tables or (y;X) pairs -- corresponding to ff arguments.
xv:{[ff;pf;fs;i]                / cross validate
 v:fs i;fs _: i;                / split training and validation sets
 a:$[type v;enlist raze fs;[v@:1;(raze;,'/)@'flip fs]]; / build ff arguments
 m:ff . a;                      / fit model on training set
 p:pf[m] v;                     / make predictions on validation set
 p}

/ k nearest neighbors

/ find (k) smallest values from (d)istance vector (or matrix) and use
/ (w)eighting (f)unction to return the best estimate of y
knn:{[wf;k;y;d]
 if[not type d;:.z.s[wf;k;y] peach d];    / recurse for matrix d
 if[any n:null d;d@:i:where not n; y@:i]; / filter null distances
 p:(waom . (wf d::;y)@\:#[;iasc d]::) peach k&count d; / make predictions
 p}

/ given (w)eighting (f)unction, (d)istance (f)unction, atom or vector of (k)
/ values, a (y) vector and matri(X), 'fit' a knn 'model'
fknn:{[wf;df;k;y;X] knn[wf;k;y] df[X]::}
pknn:@               / predict knn by applying model returned from fknn to X

/ partitional clustering initialization methods

/ generate (k) centroids by randomly choosing (k) samples from matri(X)
forgy:{[k;X]neg[k]?/:X}         / Forgy method
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
cgroup:{[df;X;C]value group imin f2nd[df X] C}

/ Stuart Lloyd's algorithm. uses (d)istance (f)unction to assign the
/ matri(X) to the nearest (C)entroid and then uses the (c)entroid (f)unction
/ to update the centroid location.
lloyd:{[df;cf;X;C]cf X@\: cgroup[df;X;C]}
/ use (r)esponsibility (f)unction David Mackay's Information Theory..(pg289)
lloyds:{[df;cf;rf;X;C] cf[rf f2nd[df X] C;X]} / soft assignment

kmeans:lloyd[edist2;avg'']      / k-means
kmedians:lloyd[mdist;med'']     / k-medians
khmeans:lloyd[edist2;hmean'']   / k harmonic means
skmeans:lloyd[cosdist;normalize (avg'')::] / spherical k-means

kmeanss:lloyds[edist2;wavg\:/:;ismin] / k-means using Lloyd with rf
/ v1 David Mackay using stiffness parameter (b)eta. 1%sqrt b represents the
/ sigma (or radius) of the cluster
kmeanssmax:{[b;X]lloyds[edist2;wavg\:/:;ssoftmax neg[b]*;X]}

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
/ using (d)istance (f)unction, matri(X) and (C)entroids, compute total
/ cluster distortion
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

/ Lance-Williams algorithm linkage functions. can be either a vector of four
/ floats or a function that accepts the cluster counts of i, j and list of
/ all cluster counts
lw.single:.5 .5 0 -.5
lw.complete:.5 .5 0 .5
lw.average:{(x%sum x _:2),0 0f}
lw.weighted:.5 .5 0 0
lw.centroid:{((x,neg prd[x]%s)%s:sum x _:2),0f}
lw.median:.5 .5 -.25 0
lw.ward:{((k+/:x 0 1),(neg k:x 2;0f))%\:sum x}

/ implementation of Lance-Williams algorithm for performing hierarchical
/ agglomerative clustering. given (l)inkage (f)unction to determine distance
/ between new and remaining clusters, (D)issimilarity matrix, cluster
/ (a)ssignments and (L)inkage stats: (j;i). returns updated (D;a;L)
lancewilliams:{[lf;D;a;L]
 n:count D;
 d:D@'di:imin peach D;                        / find closest distances
 if[null d@:i:imin d;:(D;a;L)]; j:di i;       / find closest clusters
 c:$[9h=type lf;lf;lf(freq a)@/:(i;j;til n)]; / determine coefficients
 nd:sum c*nd,(d;abs(-/)nd:D (i;j));           / calc new distances
 D[;i]:D[i]:nd;                               / update distances
 D[;j]:D[j]:n#0n;                             / erase j
 a[where j=a]:i;                / all elements in cluster j are now in i
 L:L,'(j;i);                    / append linkage stats
 (D;a;L)}

/ given a (l)inkage (f)unction and (D)issimilarity matrix, run the
/ Lance-Williams linkage algorithm for hierarchical agglomerative clustering
/ and return the linkage stats: (from index j;to index i)
link:{[lf;D]
 D:@'[D;a:til count D;:;0n];    / define cluster assignments and ignore loops
 if[-11h=type lf;lf:get lf];    / dereference lf
 L:last .[lancewilliams[lf]] over (D;a;2#()); / obtain linkage stats
 L}

/ use (L)inkage stats to create (k) clusters
clust:{[L;k]
 if[0h>type k;:first .z.s[L] k,()]; / special case atoms
 c:1 cut til 1+count L 0;           / initial clusters
 k@:i:idesc k;                      / sort k descending
 fl:(1-mk:last k)_ flip L;          / drop unwanted links
 fls:(0,-1_count[c]-k) cut fl;      / list of flipped link stats
 c:{[c;fl]{x[y 1],:x y 0;x[y 0]:();x}/[c;fl]}\[c;fls]; / link into k clusters
 c:c except\: enlist ();        / remove empty clusters
 c:c iasc i;                    / reorder based on original k
 c}

/ random variate primitives

pi:acos -1f
twopi:2f*pi
logtwopi:log twopi

/ Box-Muller
bm:{
 if[count[x] mod 2;:-1_.z.s x,rand 1f];
 x:raze (sqrt -2f*log first x)*/:(cos;sin)@\:twopi*last x:2 0N#x;
 x}

/ random number generators
/ generate (n) uniform distribution variates
runif:{[n]n?1f}
/ generate (n) Bernoulli distribution variates with (p)robability of success
rbern:{[n;p]p>runif n}
/ generate (n) binomial distribution (sum of Bernoulli) variates with (k)
/ trials and (p)robability
rbinom:{[n;k;p](sum rbern[k]::) each n#p}
/ generate (n) multinomial distribution variate-vectors with (k) trials and
/ (p)robability vector defined for each class
rmultinom:{[n;k;p](sum til[count p]=/:sums[p] binr runif::) each n#k}
/ generate (n) normal distribution variates with mean (mu) and standard
/ deviation (sigma)
rnorm:{[n;mu;sigma]mu+sigma*bm runif n}

/ C(n,k) or n choose k
choose:{[n;k](%). prd each(n-k;0)+\:1f+til k&:n-k}
/ P(n,k) or n permute k
permute:{[n;k]prd(1f+n-k)+til k}

/ [log]likelihood and maximum likelihood estimator (mle)

/ binomial likelihood (without the binomial coefficient nCk)
binl:{[n;p;k](p xexp k)*(1f-p) xexp n-k}
/ binomial log likelihood
binll:{[n;p;k](k*log p)+(n-k)*log 1f-p}
/binl:exp binll::                / more numerically stable
/ binomial mle with Dirichlet smoothing (a)
binmle:{[n;a;x]enlist avg a+x%n}
/ weighted binomial mle with Dirichlet smoothing (a)
wbinmle:{[n;a;w;x]enlist w wavg a+x%n}

/ binomial density
bind:{[n;p;k] choose[n;k]*binl[n;p;k]}

/ binomial mixture model likelihood
bmml:prd binl::
/ binomial mixture model log likelihood
bmmll:sum binll::
/bmml:exp bmmll::             / more numerically stable
/ binomial mixture model mle with Dirichlet smoothing (a)
bmmmle:{[n;a;x]enlist avg each a+x%n}
/ weighted binomial mixture model mle with Dirichlet smoothing (a)
wbmmmle:{[n;a;w;x]enlist w wavg/: a+x%n}

/ multinomial likelihood approximation (without the multinomial coefficient)
multil:{[p;k]p xexp k}
/ multinomial log likelihood
multill:{[p;k]k*log p}
/ multinomial mle with (a)dditive smoothing
multimle:{[a;x]enlist each prb a+sum each x}
/ weighted multinomial mle with (a)dditive smoothing
wmultimle:{[a;w;x]enlist each prb a+w wsum/: x}

/ multinomial mixture model likelihood
mmml:prd multil::
/ multinomial mixture model log likelihood
mmmll:sum multill::
/mmml:exp mmmll::             / more numerically stable
/ multinomial mixture model mle with Dirichlet smoothing (a)
mmmmle:{[n;a;x]enlist avg each a+x%n}
/ weighted multinomial mixture model mle with Dirichlet smoothing (a)
wmmmmle:{[n;a;w;x]enlist w wavg/: a+x%n}

/ Gaussian kernel
gaussk:{[mu;sigma;x] exp (enorm2 x-mu)%-2f*sigma}

/ Gaussian likelihood
gaussl:{[mu;sigma;x] exp[(x*x-:mu)%-2f*sigma]%sqrt sigma*twopi}
/ Gaussian log likelihood
gaussll:{[mu;sigma;x] -.5*logtwopi+log[sigma]+(x*x-:mu)%sigma}
/ Gaussian mle
gaussmle:{[x](mu;avg x*x-:mu:avg x)}
/ weighted Gaussian mle
wgaussmle:{[w;x](mu;w wavg x*x-:mu:w wavg x)}

/ Gaussian multivariate
gaussmvl:{[mu;SIGMA;X]
 if[type SIGMA;SIGMA:diag count[X]#SIGMA];
 p:exp -.5*sum X*mm[minv SIGMA;X-:mu];
 p%:sqrt mdet[SIGMA]*twopi xexp count X;
 p}
/ Gaussian multivariate log likelihood
gaussmvll:{[mu;SIGMA;X]
 if[type SIGMA;SIGMA:diag count[X]#SIGMA];
 p:sum X*mm[minv SIGMA;X-:mu];
 p+:log[mdet SIGMA]+logtwopi*count X;
 p*:-.5;
 p}
/ Gaussian multivariate mle
gaussmvmle:{[X](mu;avg X (*\:/:)' X:flip X-mu:avg each X)}
/ weighted Gaussian multivariate mle
wgaussmvmle:{[w;X](mu;w wavg X (*\:/:)' X:flip X-mu:w wavg/: X)}


/ expectation maximization

likelihood:{[l;lf;X;phi;THETA]
 p:(@[;X]lf .) peach THETA;    / compute [log] probability densities
 p:$[l;p+log phi;p*phi];       / apply prior probabilities
 p}

/ using (l)ikelihood (f)unction, (w)eighted (m)aximum likelihood estimator
/ (f)unction with prior probabilities (p)hi and distribution parameters
/ (THETA), optionally (f)fit (p)hi and perform expectation maximization
em:{[fp;lf;wmf;X;phi;THETA]
 W:prb likelihood[0b;lf;X;phi;THETA]; / weights (responsibilities)
 if[fp;phi:avg each W];               / new phi estimates
 THETA:wmf[;X] peach W;               / new THETA estimates
 (phi;THETA)}

/ term frequency primitives

/ term document matrix built from (c)orpus and (v)ocabulary
tdm:{[c;v](-1_@[(1+count v)#0;;+;1]::) each v?c}

lntf:log 1f+                       / log normalized term frequency
dntf:{[k;x]k+(1f-k)*x% max each x} / double normalized term frequency

idf: {log count[x]%sum 0<x}     / inverse document frequency
idfs:{log 1f+count[x]%sum 0<x}  / inverse document frequency smooth
idfm:{log 1f+max[x]%x:sum 0<x}  / inverse document frequency max
pidf:{log (max[x]-x)%x:sum 0<x} / probabilistic inverse document frequency
tfidf:{[tff;idff;x]tff[x]*\:idff x}

/ naive Bayes

/ fit parameters given (w)eighted (m)aximization (f)unction returns a
/ dictionary with prior and conditional likelihoods
fnb:{[wmf;w;y;X]
 if[(::)~w;w:count[y]#1f];      / handle unassigned weight
 pT:(odds g; (wmf . (w;X@\:) @\:) peach g:group y);
 pT}

/ using a [log](l)ikelihood (f)unction and prior probabilities (p)hi and
/ distribution parameters (T)HETA, perform naive Bayes classification
pnb:{[l;lf;pT;X]
 d:{(x . z) y}[lf]'[X] peach pT[1]; / compute probability densities
 c:imax $[l;log[pT 0]+sum flip d;pT[0]*prd flip d];
 c}

/ decision trees

/ classification impurity functions
misc:{1f-avg x=mode x}                  / misclassification
wmisc:{[w;x]1f-avg x=wmode[w;x]}        / weighted misclassification
gini:{1f-enorm2 odds group x}           / Gini
wgini:{[w;x]1f-enorm2 wodds[w] group x} / weighted Gini
entropy:{neg sum x*log x:odds group x}  / entropy
wentropy:{[w;x]neg sum x*log x:wodds[w] group x} / weighted entropy

/ regression impurity functions
mse:{enorm2[x-avg x]%count x}          / mean squared error
wmse:{[w;x]enorm2[x-w wavg x]%count x} / weighted mean squared error
mae:{avg abs x-avg x}                  / mean absolute error
wmae:{[w;x]avg abs x-w wavg x}         / weighted mean absolute error

rms:{sqrt avg x*x}              / root mean square error

/ combinations of length x (or all lengths if null x) from count (or list) y
cmb:{
 if[not 0>type y;:y .z.s[x] count y];    / list y
 if[null x;:raze .z.s[;y] each 1+til y]; / null x = all lengths
 c:flip enlist flip enlist til y-:x-:1;
 c:raze c {(x+z){raze x,''y}'x#\:y}[1+til y]/til x;
 c}

/ use (i)m(p)urity (f)unction to compute the (w)eighted information gain of
/ x after splitting on y
ig:{[ipf;w;x;y]                 / information gain
 g:ipf[w] x;
 g-:sum wodds[w;gy]*(not null key gy)*w[gy] ipf' x gy:group y;
 (g;::;gy)}

/ use (i)m(p)urity (f)unction to compute the (w)eighted gain ratio of x
/ after splitting on y
gr:{[ipf;w;x;y]                 / gain ratio
 g:ig[ipf;w;x;y];               / first compute information gain
 g:@[g;0;%[;ipf[w;y]]];         / then divide by splitinfo
 g}

/ use (i)m(p)urity (f)unction to pick the maximum (w)eighted information
/ gain of x after splitting across all sets of distinct y
sig:{[ipf;w;x;y]                / set information gain
 c:raze cmb[;u] peach 1+til 1|count[u:distinct y] div 2; / combinations of y
 g:(ig[ipf;w;x] y in) peach c;                           / all gains
 g@:i:imax g[;0];                                        / highest gain
 g[1]:in[;c i];                 / replace split func
 g}

/ use (i)m(p)urity (f)unction to pick the maximum (w)eighted information
/ gain of x after splitting across all values of y
oig:{[ipf;w;x;y]                             / ordered information gain
 g:(ig[ipf;w;x] y >) peach u:asc distinct y; / all gains
 g@:i:imax g[;0];                            / highest gain (not gain ratio)
 g[1]:>[;avg u i+0 1];                       / replace split func
 g}

/ use (i)m(p)urity (f)unction to pick the maximum (w)eighted gain ratio of x
/ after splitting across all values of y
ogr:{[ipf;w;x;y]                / ordered gain ratio
 g:oig[ipf;w;x;y];              / first compute information gain
 g:@[g;0;%[;ipf[w;g[1] y]]];    / then divide by splitinfo
 g}

/ given a vector of (w)eights (or ::) and a (t)able of features where the
/ first column is the target attribute, create a decision tree using the
/ (c)ategorical (g)ain (f)unction and (o)rdered (g)ain (f)unction. the
/ (i)m(p)urity (f)unction determines which statistic to minimize. a dict of
/ (opt)ions specify the (max) (d)epth, (min)imum # of (s)amples required to
/ (s)plit, (min)imum # of (s)amples at each (l)eaf, (min)imum (g)ain and the
/ (max)imum (f)eature (f)unction used to sub sample features for random
/ forests.  defaults are: opt:`maxd`minss`minsl`ming`maxff!(0N;2;1;0;::)
dt:{[cgf;ogf;ipf;opt;w;t]
 if[(::)~w;w:n#1f%n:count t];       / compute default weight vector
 if[1=count d:flip t;:(w;first d)]; / no features to test
 opt:(`maxd`minss`minsl`ming`maxff!(0N;2;1;0;::)),opt; / default options
 if[0=opt`maxd;:(w;first d)];    / check if we've reached max depth
 if[identical a:first d;:(w;a)]; / check if all values are equal
 if[opt[`minss]>count a;:(w;a)]; / check if insufficient samples
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

/ use decision (tr)ee to make predictions for (d)ictionary
pdt:{[tr;d]
 if[98h=type d;:.z.s[tr] peach d]; / iterate on a table
 p:waom . pdtr[tr;d];
 p}
/ use decision (tr)ee to recursively find leaf/leaves for (d)ictionary
pdtr:{[tr;d]
 if[2=count tr;:tr];            / (w;a)
 if[not null k:d tr 0;if[(a:tr[1][k]) in key tr[2];:.z.s[tr[2] a;d]]];
 v:(,'/) tr[2] .z.s\: d;    / dig deeper for null values
 v}

/ decision tree pruning primitives

/ Wilson score - binary confidence interval (Edwin Bidwell Wilson)
wscore:{[z;f;n](f+(.5*z2n)+-1 1f*z*sqrt((.25*z2n)+f-f*f)%n)%1f+z2n:z*z%n}
/ pessimistic error
perr:{[z;w;x]last wscore[z;wmisc[w;x];count x]}

/ use (e)rror (f)unction to post-prune (tr)ee
prune:{[ef;tr]
 if[2=count tr;:tr];               / (w;a)
 b:value tr[2]:.z.s[ef] each tr 2; / prune subtree
 if[any 3=count each b;:tr];       / can't prune
 e:ef . wa:(,'/) b;                / pruned error
 if[e<((sum first::) each b) wavg (ef .) each b;:wa];
 tr}

/ return the leaves of (tr)ee
leaves:{[tr]$[2=count tr;enlist tr;raze .z.s each last tr]}

/ using (e)rror (f)unction, return the decision (tr)ee's risk R(T) and
/ number of terminal nodes |T|
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
dtxv:{[dtf;ef;a;ts]xv[dtmincc[ef]\[;a]dtf::;pdt\:/:;ts]}

/ use (train;test) (i)ndices to cross validate (t)able using (d)ecision
/ (t)ree (f)unction, (a)lphas and misclassification (e)rror (f)unction
dtcv:{[dtf;ef;a;t;i]cv[dtmincc[ef]\[;a]dtf::;pdt\:/:;t;i]}

/ decision tree utilities

/ print leaf: prediction followed by classification error% or regression sse
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

/ given (p)arent id, (n)ode id, label and (tr)ee print Graphviz node
pnode:{[p;n;l;tr]
 s:n," [label = \"";                                         / label
 st:$[b:2=count tr;();tr 2];                                 / sub tree
 cn:n,/:"0"^(neg max count each cn)$ cn:string til count st; / child node ids
 c:$[b;enlist (tr;st);.z.s[n]'[cn;key st;value st]];         / children
 s,:pleaf . x:(,'/) first each c;                            / error stats
 if[not b;s,:"\\n",raze string[2#tr],\: " "];                / node title
 s:enlist s,"\"]";
 if[count p;s,:enlist p," -> ",n," [label = \"",string[l],"\"]"]; / edge
 s,:raze last each c;
 (x;s)}

/ print graph text for use with the 'dot' Graphviz command, graph-easy or
/ http://webgraphviz.com
pgraph:{[tr]
 s:enlist "digraph Tree {";
 s,:enlist "node [shape = box]";
 s,:last pnode["";"0";`;tr];
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
/ replacement) (t)able
bag:{[n;f;t](f ?[;t]::) peach n#count t} / (b)ootstrap (ag)gregating

/ given an atom or list (k), and bootstrap aggregating (m)odel, make
/ prediction on (d)ictionary
pbag:{[k;m;d]
 if[count[m]<max k;'`length];
 if[98h=type d;:.z.s[k;m] peach d]; / iterate on a table
 p:k {aom x#y}\: pdt[;d] peach m;
 p}

/ discrete adaptive boosting

/ given (t)rain (f)unction, discrete (c)lassifier (f)unction, initial
/ (w)eights, and (t)able with -1 1 discrete target class values in first
/ column, return ((m)odel;(a)lpha;new (w)eights)
adaboost:{[tf;cf;w;t]
 if[(::)~w;w:n#1f%n:count t];    / initialize weights
 m:tf[w] t;                      / train model
 p:cf[m] t;                      / make predictions
 e:sum w*not p=y:first flip t;   / compute weighted error
 a:.5*log (c:1f-e)%e;            / compute alpha (minimize exponential loss)
 / w*:exp neg a*y*p;               / increase/decrease weights
 / w%:sum w;                       / normalize weights
 w%:2f*?[y=p;c;e];               / increase/decrease and normalize weights
 (m;a;w)}

/ given an atom or list (k), (t)rain (f)unction, discrete (c)lassifier
/ (f)unction, and (t)able perform max(k) iterations of adaboost
fab:{[k;tf;cf;t] 1_max[k] (adaboost[tf;cf;;t] last::)\ (::)}

/ given an atom or list (k), discrete (c)lassifier function, adaboost
/ (m)odel, make prediction on (d)ictionary
pab:{[k;cf;m;d]
 if[count[m]<mx:max k;'`length];
 if[98h=type d;:.z.s[k;cf;m] peach d]; / iterate on a table
 p:m[;1] * cf[;d] peach m[;0];
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

/ print # of iterations, current (c)ost and % decrease to (h)andle, return a
/ continuation boolean: % decrease > float (p) or iterations < integer (p)
continue:{[h;p;c]
 pct:$[2>n:count c;0w;1f-(%/)c n-1 2];
 b:$[-8h<type p;p>n;p<pct];
 s:" | " sv ("iter: ";"cost: ";"pct: ") ,' string (n;last c;pct);
 if[not null h; h s,"\n\r" b];
 b}

/ keep calling (m)inimization (f)unction on (THETA) and logging status to
/ (h)andle until the % decrease in the (c)ost (f)unction is less than
/ (p). return (cost vector;THETA)
iter:{[h;p;cf;mf;THETA](continue[h;p]last::)acccost[cf;mf]//(::;cf)@\:THETA}

/ (a)lpha: learning rate, gf: gradient function
gd:{[a;gf;THETA] THETA-a*gf THETA} / gradient descent

/ optimize (THETA) by using gradient descent with learning rate (a) and
/ (g)radient (f)unction over (n) subsamples of (X) and (Y) generated with
/ (s)ampling (f)unction: til = no shuffle, 0N? = shuffle, {x?x} = bootstrap
sgd:{[a;gf;sf;n;Y;X;THETA]        / stochastic gradient descent
 I:(n;0N)#sf count X 0;
 THETA:THETA (gd[a] . (gf .;::)@'{(x[;;z];y)}[(Y;X)]::)/ I;
 THETA}

/ linear regression

/ given target matrix Y and data matri(X), return the THETA matrix resulting
/ from minimizing sum of squared residuals
normeq:{[Y;X]mm[mmt[Y;X]] minv mmt[X;X]} / normal equations ols

/ given (l2) regularization parameter, target matrix Y and data matri(X),
/ return the THETA matrix resulting from performing ridge regression
ridge:{[l2;Y;X]mm[mmt[Y;X]] minv mmt[X;X]+diag count[X]#l2}

/ given (l2) regularization parameter, target vector y and data matri(X),
/ return theta vector resulting from performing weighted ridge regression by
/ scaling the regularization parameter by the count of non-null values
wridge:{[l2;y;X]first ridge[l2*count i;enlist y i;X[;i:where not null y]]}

/ linearly predict Y values by prepending matri(X) with a vector of 1s and
/ multiplying the result to (THETA) coefficients
plin:{[X;THETA]mm[THETA] prepend[1f] X}

/ linear regression cost
lincost:{[rf;Y;X;THETA]
 J:(.5%m:count X 0)*revo[sum] E*E:plin[X;THETA]-Y;         / cost
 if[count rf,:();THETA[;0]:0f; J+:sum rf[;m][;0][;THETA]]; / regularization
 J}

/ linear regression gradient
lingrad:{[rf;Y;X;THETA]
 G:(1f%m:count X 0)*mmt[0f^mm[THETA;X]-Y] X:prepend[1f] X; / gradient
 if[count rf,:();THETA[;0]:0f; G+:sum rf[;m][;1][;THETA]]; / regularization
 G}

/ linear cost & gradient
lincostgrad:{[rf;Y;X;theta]
 THETA:(count Y;0N)#theta; X:prepend[1f] X;         / unroll theta
 J:(.5%m:count X 0)*revo[sum] E*E:0f^mm[THETA;X]-Y; / cost
 G:(1f%m)*mmt[E] X;                                 / gradient
 if[count rf,:();THETA[;0]:0f;JG:rf[;m][;;THETA];J+:sum JG@'0;G+:sum JG@'1];
 (J;raze G)}

/ activation primitives (derivatives optionally accept `z`a!(z;a) dict)

linear:(::)                                   / linear
dlinear:{1f+0f*$[99h=type x;x`z;x]}           / linear gradient
sigmoid:1f%1f+exp neg::                       / sigmoid
dsigmoid:{x*1f-x:$[99h=type x;x`a;sigmoid x]} / sigmoid gradient
tanh:1f-2f%1f+exp 2f*                         / hyperbolic tangent
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
plog:sigmoid plin::

/ logistic regression cost
logcost:{[rf;Y;X;THETA]
 J:(1f%m:count X 0)*revo[sum] logloss[Y] plog[X;THETA];    / cost
 if[count rf,:();THETA[;0]:0f; J+:sum rf[;m][;0][;THETA]]; / regularization
 J}

/ logistic regression gradient
loggrad:{[rf;Y;X;THETA]
 G:(1f%m:count X 0)*mmt[sigmoid[mm[THETA;X]]-Y] X:prepend[1f] X; / gradient
 if[count rf,:();THETA[;0]:0f; G+:sum rf[;m][;1][;THETA]]; / regularization
 G}

logcostgrad:{[rf;Y;X;theta]
 THETA:(count Y;0N)#theta; X:prepend[1f] X; / unroll theta
 J:(1f%m:count X 0)*revo[sum] logloss[Y] P:sigmoid mm[THETA] X; / cost
 G:(1f%m)*mmt[P-Y] X;                                           / gradient
 if[count rf,:();THETA[;0]:0f;JG:rf[;m][;;THETA];J+:sum JG@'0;G+:sum JG@'1];
 (J;raze G)}

logcostgradf:{[rf;Y;X]
 Jf:logcost[rf;Y;X]enlist::;
 Gf:loggrad[rf;Y;X]enlist::;
 (Jf;Gf)}

/ one vs all

/ given binary classification fitting (f)unction, fit a one-vs.-all model
/ against Y for each unique (lbls)
fova:{[f;Y;lbls] (f "f"$Y=) peach lbls}

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
pnn:{[hof;X;THETA]
 X:X (hof[`h] plin::)/ -1_THETA;
 Y:hof[`o] plin[X] last THETA;
 Y}

/ (r)egularization (f)unction, holf: (h)idden (o)utput (l)oss functions
nncost:{[rf;holf;Y;X;THETA]
 J:(1f%m:count X 0)*revo[sum] holf[`l][Y] pnn[holf;X] THETA; / cost
 if[count rf,:();THETA[;;0]:0f;J+:sum rf[;m][;0][;THETA]]; / regularization
 J}

/ (r)egularization (f)unction, hgof: (h)idden (g)radient (o)utput functions
nngrad:{[rf;hgof;Y;X;THETA]
 ZA:enlist[(X;X)],(X;X) {(z;x z:plin[y 1;z])}[hgof`h]\ -1_THETA;
 P:hgof[`o] plin[last[ZA]1;last THETA]; / prediction
 G:hgof[`g]@'`z`a!/:1_ZA;               / activation gradient
 D:reverse{[D;THETA;G]G*1_mtm[THETA;D]}\[E:P-Y;reverse 1_THETA;reverse G];
 G:(1%m:count X 0)*(D,enlist E) mmt' prepend[1f] each ZA[;1]; / full grad
 if[count rf,:();THETA[;;0]:0f; G+:sum rf[;m][;1][;THETA]]; / regularization
 G}

/ neural network cut
nncut:{[n;x]n cut' sums[prev[n+:1]*n:-1_n] cut x}

/ (r)egularization (f)unction, (n)etwork topology dimensions, hgolf:
/ (h)idden (g)radient (o)utput (l)oss functions
nncostgrad:{[rf;n;hgolf;Y;X;theta]
 THETA:nncut[n] theta;          / unroll theta
 ZA:enlist[(X;X)],(X;X) {(z;x z:plin[y 1;z])}[hgolf`h]\ -1_THETA;
 P:hgolf[`o] plin[last[ZA]1;last THETA];      / prediction
 J:(1f%m:count X 0)*revo[sum] hgolf[`l][Y;P]; / cost
 G:hgolf[`g]@'`z`a!/:1_ZA;                    / activation gradient
 D:reverse{[D;THETA;G]G*1_mtm[THETA;D]}\[E:P-Y;reverse 1_THETA;reverse G];
 G:(1f%m)*(D,enlist E) mmt' prepend[1f] each ZA[;1]; / full gradient
 if[count rf,:();THETA[;;0]:0f;JG:rf[;m][;;THETA];J+:sum JG@'0;G+:sum JG@'1];
 (J;2 raze/ G)}

/ collaborative filtering

/ collaborative filtering predict
pcf:{[X;THETA] mtm[THETA;X]}

/ collaborative filtering cost
cfcost:{[rf;Y;X;THETA]
 J:(.5f%m:count X 0)*revo[sum] E*E:pcf[X;THETA]-Y; / cost
 if[count rf,:();J+:sum rf[;m][;0]@\:(X;THETA)];   / regularization
 J}

/ collaborative filtering gradient
cfgrad:{[rf;Y;X;THETA]
 G:(1f%m:count X 0)*(mm[THETA;E];mmt[X]E:0f^pcf[X;THETA]-Y); / gradient
 if[count rf,:();G+:sum rf[;m][;1]@\:(X;THETA)]; / regularization
 G}

/ collaborative filtering cut where n:(ni;nu)
cfcut:{[n;x]n cut'(0,n[0]*count[x]div sum n) cut x}

/ collaborative filtering cost & gradient
cfcostgrad:{[rf;n;Y;xtheta]
 THETA:last X:cfcut[n] xtheta;X@:0; / unroll theta
 J:(.5%m:count X 0)*revo[sum] E*E:0f^pcf[X;THETA]-Y; / cost
 G:(1f%m)*(mm[THETA;E];mmt[X;E]);                    / gradient
 if[count rf,:();JG:rf[;m][;;(X;THETA)];J+:sum JG@'0;G+:sum JG@'1];
 (J;2 raze/ G)}

/ using learning rate (a)lpha, and (l2) regularization parameter, factorize
/ matrix Y using stochastic gradient descent by solving for each non null
/ value one at a time.  (s)ampling (f)unction: til = no shuffle, 0N? =
/ shuffle, {x?x} = bootstrap.  pass (::) for xy to initiate sgd.
sgdmf:{[a;l2;sf;Y;XTHETA;xy] / sgd matrix factorization
 if[(::)~xy;:XTHETA .z.s[a;l2;sf;Y]/ I sf count I:flip twhere not null Y];
 e:(Y . xy)-dot . xt:XTHETA .'I:flip(::;xy 1 0); / error
 XTHETA:./[XTHETA;0 1,'I;+;a*(e*xt 1 0)-l2*xt];  / adjust X and THETA
 XTHETA}

/ ALS-WR (a)lternating (l)east (s)quares with (w)eighted (r)egularization
alswr:{[l2;Y;XTHETA]
 X:flip f2nd[wridge[l2;;XTHETA 1]] Y; / hold THETA constant, solve for X
 THETA:flip wridge[l2;;X] peach Y;    / hold X constant, solve for THETA
 (X;THETA)}

/ top n svd factors
nsvd:{[n;usv]n#''@[usv;1;(n:min n,count each usv 0 2)#]}

/ use svd decomposition to predict missing exposures for new user
/ (ui=0b) or item (ui=1b) (r)ecord
foldin:{[usv;ui;r]@[usv;0 2 ui;,;mm[enlist r] mm[usv 2 0 ui] minv usv 1]}

/ gradient checking primitives

/ compute numerical gradient of (f)unction evaluated at x using steps of
/ size (e)psilon. compute partial derivatives if (e)psilon is a list
numgrad:{[f;x;e](.5%e)*{x[y+z]-x[y-z]}[f;x] peach diag e}

/ return analytic gradient using (g)radient (f)unction and numerical
/ gradient by evaluating (c)ost (f)unction on theta perturbed by (e)psilon
checkgrad:{[e;cf;gf;theta]
 ag:gf theta;                         / analytic gradient
 ng:numgrad[cf;theta] count[theta]#e; / numerical gradient
 (ag;ng)}

/ hgolf: (h)idden (g)radient (o)utput (l)oss functions
checknngrad:{[e;rf;n;hgolf]
 theta:2 raze/ glorotu'[1+-1_n;1_n];          / initialize theta
 X:glorotu[n 1;n 0];                          / random X matrix
 y:1+(1+til n 1) mod last n;                  / random y vector
 Y:flip eye[last n]"i"$y-1;                   / transform into Y matrix
 cgf:nncostgrad[rf;n;hgolf;Y;X];              / cost gradient function
 r:checkgrad[e;first cgf::;last cgf::;theta]; / generate gradients
 r}

checkcfgrad:{[e;rf;n]
 ni:n 0;nu:n 1 ;nf:10;          / (n) (i)tems, (n) (u)sers, (n) (f)eatures
 xtheta:2 raze/ (X:ni?/:nf#1f;THETA:nu?/:nf#1f); / initialize theta
 Y:mm[nf?/:nu#1f]ni?/:nf#1f;                     / random recommendations
 Y*:0N 1@.5<ni?/:nu#1f;                          / drop some recommendations
 cgf:cfcostgrad[rf;n;Y];                         / cost gradient function
 r:checkgrad[e;first cgf::;last cgf::;xtheta];   / generate gradients
 r}

/ sparse matrix manipulation

/ shape of a tensor (atom, vector, matrix, etc)
shape:{$[0h>t:type x;0#0;n:count x;n,.z.s x 0;1#0]}
/ rank of a tensor (atom, vector, matrix, etc)
dim:count shape::
/ sparse from tensor
sparse:{(shape x;(x') . I),I:twhere "b"$x}
/ tensor from sparse
full:{./[x[0]#0f;flip 2_x;:;x 1]}
/ sparse matrix transpose
smt:{(reverse x 0;x 1;x 3;x 2)}
/ sparse matrix multiplication
smm:{
 t:ej[`;flip `v``c!1_y;flip`w`r`!1_x];
 t:0!select sum w*v by c,r from t;
 m:enlist[(x[0;0];y[0;1])],reverse value flip t;
 m}
/ sparse matrix addition
sma:{
 t:flip[`v`r`c!1_y],flip`v`r`c!1_x;
 t:0!select sum v by c,r from t;
 m:enlist[x 0],reverse value flip t;
 m}

/ Google PageRank

/ given a (d)amping factor (1 - the probability of random surfing) and the
/ (A)djacency matrix, create the Markov Google matrix
google:{[d;A]
 M:A%1f|s:sum each A;           / convert to Markov matrix
 M+:(0f=s)%n:count M;           / add links to dangling pages
 M:(d*M)+(1f-d)%n;              / dampen
 M}

/ given a (d)amping factor (1 - the probability of random surfing) and the
/ (A)djacency matrix, obtain the pagerank algebraically
pageranka:{[d;A]
 M:A%1f|s:sum each A;           / convert to Markov matrix
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
 w:sum r*0f=s:0f^sum'[S[1] group S 2]til n:S[0;0]; / compute dangling weight
 r:first full[smm[sparse enlist r%1f|s;S]]+w%n;    / compute rankings
 r:(d*r)+(1f-d)%n;                                 / dampen
 r}

/ dimensionality reduction

covm:{[X] mmt[X;X]%count X 0}     / covariance matrix
pca:{[X] last .qml.mev covm X}    / eigen vectors of scatter matrix
project:{[V;X] mtm[V] mm[V;X]}    / project X onto subspace V

/ Markov clustering

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

cmul:{((-/)x*y;(+/)x*(|)y)}     / complex multiplication
csqr:{((-/)x*x;2f*(*/)x)}       / complex square

/ Mandelbrot

mbrotf:{[c;x]c+csqr x}                     / Mandelbrot function
mbrotp:{not 4f<0w^enorm2 x}                / Mandelbrot predicate
mbrota:{[c;x;n](x;n+mbrotp x:mbrotf[c;x])} / Mandelbrot accumulator
