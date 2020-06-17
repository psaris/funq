\l funq.q
\l iris.q

/ markov clustering
/ https://www.cs.ucsb.edu/~xyan/classes/CS595D-2009winter/MCL_Presentation2.pdf

/ example from mcl man page
/ http://micans.org/mcl/man/mcl.html
t:flip `k1`k2`v!"ssf"$\:()
t,:`cat`hat,0.2
t,:`hat`bat,0.16
t,:`bat`cat,1.0
t,:`bat`bit,0.125
t,:`bit`fit,0.25
t,:`fit`hit,0.5
t,:`hit`bit,0.16

/ take max of bidirectional links, enumerate keys
k:()
m:.ml.inflate[1;0f] .ml.addloop m|:flip m:.ml.full enlist[2#count k],exec (v;`k?k1;`k?k2) from t
.util.assert[(`hat`bat`cat;`bit`fit`hit)] (get`k!) each .ml.interpret .ml.mcl[2;1.5;0f] over m

/ cluster the iris data
sm:.5<.ml.gaussk[iris.X;.5] each flip iris.X / similarity matrix based on Gaussian kernel
show .ml.interpret .ml.mcl[2;1.5;10] over .ml.inflate[1;0f] sm
/ are there 4 species: http://www.siam.org/students/siuro/vol4/S01075.pdf

