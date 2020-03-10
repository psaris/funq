\c 20 100
\l funq.q

/ define a plotting function using 10 characters of gradation
plt:.util.plot[w:40;h:20;c:.util.c10;sum]

-1"plotting 1-dimensional dataset (sin x): x";
-1 value plt X:sin .01*til 1000;

-1"plotting 2-dimensional dataset (uniform variates): (x;y)";
-1 value plt X:10000?/:2#1f;

-1"plotting 2-dimensional dataset (normal variates): (x;y)";
-1 value plt (.ml.bm 10000?) each 2#1f;

-1"plotting 3-dimensional dataset: (x;y;z)";
-1 value plt {(x;{x*x*x}x-.5;x:til[x]%x)} 1000;

-1"plotting 3-dimensional grid as a heatmap: X (matrix)";
-1 value plt .util.hmap {x*/:(x:til x)*(x;x)#1f} 1000;

b:1b / use binary encoding for portable (bit|pix)map

-1"plotting mandelbrot series black/white";
c:.util.tcross . (.util.nbin .) each flip (-1+w:1000;-2 -1.25;.5 1.25)
x:w cut .ml.mbrotp 20 .ml.mbrotf[c]/0f
-1 value  plt .util.hmap x;
`mandel.pbm 0: .util.pbm[b] x;

-1"plotting mandelbrot series gray scale";
x:w cut last 20 .ml.mbrota[c]// (0f;0)
-1 value plt .util.hmap x;
`mandel.pgm 0: .util.pgm[b;20] x;

-1"plotting mandelbrot series color";
`mandel.ppm 0: .util.ppm[b;20] flip[(rand 1+20;til 1+20;rand 1+20)] x;

/ tests
.util.assert[1b] last[x]<last .util.heckbert[4] . x:.47 .56
.util.assert[1b] last[x]<last .util.heckbert[10] . x:32064 64978f
