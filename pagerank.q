\c 20 100
\l funq.q
\l cloud9.q
\l berkstan.q

/ http://ilpubs.stanford.edu:8090/422/
/ http://infolab.stanford.edu/~backrub/google.html
/ https://ahrefs.com/blog/google-pagerank/
/ https://en.wikipedia.org/wiki/Google_matrix
/ https://en.wikipedia.org/wiki/PageRank
/ http://www.cs.princeton.edu/~chazelle/courses/BIB/pagerank.htm
/ http://www.mathworks.com/help/matlab/examples/use-page-rank-algorithm-to-rank-websites.html
/ https://www.mathworks.com/moler/exm/chapters/pagerank.pdf

-1 "given a list of page links,";
i:1 1 2 2 3 3 3 4 6
j:2 6 3 4 4 5 6 1 1
show l:(i;j)
node:asc distinct raze l
l:node?l
-1 "we can transform the sparse connectivity matrix";
show S:(1 2#1+max over l), .ml.append[1f] l
-1 "into a full matrix";
show A:.ml.full S
-1 "using matrix inversion, we can algebraically compute the pagerank";
-1 "it is commonly understood that the odds of clicking on a link are 85%";
-1 "while the odds of randomly going to another page are 15%";
d:.85
show node[i]!r i:idesc r:.ml.pageranka[d;A]
-1 "ranks don't change drastically over time";
-1 "so perhaps an iterative approach is better";
show node[i]!r i:idesc r:.ml.pageranki[d;A] over r:n#1f%n:count A
S:.ml.sparse A                  / sparse matrix
show node[i]!r i:idesc r:.ml.pageranks[d;S] over r:n#1f%n:S[0;0]
-1 "this can be optimized by using the power method";
-1 "first compute the Google matrix, then iteratively multiply until convergence";
show node[i]!r i:idesc r:$[;.ml.google[d;A]] over r:n#1f%n:count A


/ https://lintool.github.io/Cloud9/docs/exercises/pagerank.html
node:asc distinct raze cloud9.l
l:node?cloud9.l
show S:(1 2#1+max over l), .ml.append[1f] l
show node[i]!r i:idesc r:.ml.pageranks[d;S] over r:n#1f%n:S[0;0]
-1 "into a full matrix";
show A:.ml.full S
show node[i]!r i:idesc r:.ml.pageranka[d;A]
show node[i]!r i:idesc r:.ml.pageranki[d;A] over r:n#1f%n:count A
show node[i]!r i:idesc r:$[;.ml.google[d;A]] over r:n#1f%n:count A

node:asc distinct raze berkstan.l
l:node?berkstan.l
show S:(1 2#1+max over l), .ml.append[1f] l
-1"not enough memory to convert sparse -> full matrix";
-1"just perform a few sparse iterations";
show node[i]!r i:idesc r:10 .ml.pageranks[d;S]/ r:n#1f%n:S[0;0]
