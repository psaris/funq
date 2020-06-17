\c 20 100
\l funq.q

-1 "given a matrix with many missing values,";
show X:"f"$(100;100)#0 0 1
-1 "we can record the non-zero values to create a sparse matrix";
show S:.ml.sparse X
-1 "the representation includes the number of rows and columns";
-1 "followed by the x and y coordinates and finally the matrix valus";
.util.assert[X] .ml.full S      / matrix -> sparse -> matrix == matrix
/ sparse matrix multiplication == mmu
-1 "we can perform sparse matrix transposition";
.util.assert[flip X] .ml.full .ml.smt S
-1 "sparse matrix multiplication";
.util.assert[X$X] .ml.full .ml.smm[S;S]
-1 "sparse matrix addition";
.util.assert[X+X] .ml.full .ml.sma[S;S]
-1 "sparse tensors";
.util.assert[T] .ml.full .ml.sparse T:2 3 4#0 1f

