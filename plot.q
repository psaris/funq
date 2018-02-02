\d .plot

nbin:{(til[y]%y) bin 0f^x%max x-:min x} / allocate x into y bins

nrng:{[n;s;e]s+til[1+n]*(e-s)%n} / divide range (s;e) into n buckets

/ cut m x n matrix X into (x;y;z) where x and y are the indices for X
/ and z is the value stored in X[x;y] - result used to plot heatmaps
hmap:{[X]
 t:([]x:til count X) cross ([]y:reverse til count X 0); / cross table!
 X:value[flip t],enlist raze X;
 X}

/ plot X using (c)haracters limited to (w)idth and (h)eight
/ X can be x, (x;y), (x;y;z), ([]x), ([]x;y), ([]x;y;z), x!y
plot:{[w;h;c;X]
 if[98h=t:type X;X:value flip X];     / convert table to matrix
 if[99h=t;X:(key;value)@\:X];         / convert dictionary to matrix
 if[t within 1 19h;X:enlist X];       / promote vector to matrix
 if[1=count X;X:(til count X 0;X 0)]; / turn ,x into (x;y)
 if[2=count X;X,:count[X 0]#1];       / turn (x;y) into (x;y;z)
 Z:@[X;0 1;nbin;(w;h)];               / allocate (x;y) to (w;h) bins
 Z:flip key[Z],'avg each value Z:Z[2]g:group flip 2#Z; / avg overlapping z
 Z:@[Z;2;nbin;cn:count c,:()];                         / binify z
 p:h#enlist w#" ";                                     / empty canvas
 p:./[p;flip Z 1 0;:;c Z 2];                           / plot points
 k:nrng[h-1] . (min;max)@\:X 1;                        / compute key
 p:reverse k!p;                                        / generate plot
 p}

c10:" .-:=+x#%@"                         / 10 characters
c16:" .-:=+*xoXO#$&%@"                   / 16 characters
c68:" .'`^,:;Il!i><~+_-?][}{1)(|/tfjrxn" / 68 characters
c68,:"uvczXYUJCLQ0OZmwqpdbkhao*#MW&8%B@$"

plt:plot[59;30;1_c16]           / default plot function
