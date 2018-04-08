\c 20 100
\l funq.q

/ http://www.cs.princeton.edu/~chazelle/courses/BIB/pagerank.htm
/ http://www.mathworks.com/help/matlab/examples/use-page-rank-algorithm-to-rank-websites.html

/ s:"aaabbcddd"
/ t:"bcddabcab"
/ S:(1 2#1+max raze 2#S),S:.ml.append[1f] distinct[s,t]?/:(s;t)
/ X:.ml.full S

/ https://www.mathworks.com/moler/exm/chapters/pagerank.pdf

-1 "given a list of page links,";
i:1 1 2 2 3 3 3 4 6
j:2 6 3 4 4 5 6 1 1
show i!j
-1 "we can transform the sparse connectivity matrix";
show S:(1 2#max i,j), .ml.append[1f] (i;j)-1
-1 "into a full matrix";
show X:.ml.full S
-1 "using matrix inversion, we can compute the pagerank of a full matrix";
show .ml.drank .ml.pageranki[.85;X]
\
/ https://en.wikipedia.org/wiki/PageRank
\ts:1000 .ml.drank .ml.pagerankr[.85;X] over r:n#1f%n:count X

/ https://en.wikipedia.org/wiki/Google_matrix
X:(01100000b;10001000b;01000001b;00100000b;00010001b;00011000b;00010100b;10010010b)
.ml.drank .ml.pageranki[.85;X]     / matrix inversion
.ml.drank .ml.pagerankr[.85;"f"$X] over r:n#1f%n:count X / function iteration
.ml.drank $[;.ml.google[.85;X]] over r:n#1f%n:count X    / non-sparse matrix iteration

s:1 2 3 3 3 4 4
t:2 1 1 3 5 3 5
S:(1 2#max s,t), .ml.append[1f] (s;t)-1
X:.ml.full S
.ml.drank .ml.pageranki[.85;X]
.ml.drank .ml.pagerankr[.85;"f"$X] over r:n#1f%n:count X
.ml.drank $[;.ml.google[.85;X]] over r:n#1f%n:count X

