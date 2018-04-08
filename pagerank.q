\c 20 100
\l funq.q

/ https://en.wikipedia.org/wiki/Google_matrix
/ https://en.wikipedia.org/wiki/PageRank
/ http://www.cs.princeton.edu/~chazelle/courses/BIB/pagerank.htm
/ http://www.mathworks.com/help/matlab/examples/use-page-rank-algorithm-to-rank-websites.html
/ https://www.mathworks.com/moler/exm/chapters/pagerank.pdf

-1 "given a list of page links,";
i:1 1 2 2 3 3 3 4 6
j:2 6 3 4 4 5 6 1 1
show i!j
-1 "we can transform the sparse connectivity matrix";
show S:(1 2#max i,j), .ml.append[1f] (i;j)-1
-1 "into a full matrix";
show X:.ml.full S
-1 "using matrix inversion, we can algebraically compute the pagerank";
-1 "it is commonly understood that the odds of clicking on a link are 85%";
-1 "while the odds of randomly going to another page are 15%";
p:.85
show .ml.drank .ml.pageranka[p;X]
-1 "ranks don't change drastically over time";
-1 "so perhaps an iterative approach is better";
show .ml.drank .ml.pageranki[p;X] over r:n#1f%n:count X
-1 "this can be optimized by using the power method";
-1 "first compute the google matrix, then iteratively multiply until convergence";
show .ml.drank $[;.ml.google[p;X]] over r:n#1f%n:count X / TODO: implement sparse version
