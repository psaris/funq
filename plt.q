\c 20 100
\l funq.q

/ define a plotting function using 10 characters of gradation
plt:.plot.plot[28;15;1_.plot.c10]

-1"plotting 1-dimensional dataset (sin x): x";
show plt sin .01*til 1000

-1"plotting 2-dimensional dataset (uniform variates): (x;y)";
plt 100?/:100#1f

-1"plotting 2-dimensional dataset (normal variates): (x;y)";
/ k6 has introduced this as: n?-1f
show plt (.ml.bm 100?) each 100#1f

-1"plotting 3-dimensional dataset: (x;y;z)";
show plt {(x;{x*x*x}x-.5;x:til[x]%x)} 1000

-1"plotting 3-dimensional grid as a heatmap: X (matrix)";
show plt .plot.hmap {x*/:(x:til x)*(x;x)#1f} 1000

-1"plotting a dictionary";
show plt {x!1%x}1+til 10

-1"plotting a table";
show plt {([]date:.z.D+til x;price:sums .ml.bm x?1f)} 1000