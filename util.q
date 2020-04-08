\d .util

/ data loading utilities

/ load (f)ile if it exists and return success boolean
loadf:{[f]if[()~key f;:0b];system "l ",1_string f;1b}

unzip:$["w"=first string .z.o;"7z.exe x -y -aos";"unzip -n"]
gunzip:$["w"=first string .z.o;"7z.exe x -y -aos";"gunzip -f -N -v"]
untar:"tar -xzvf"               / tar is now in windows 10 system32

/ (b)ase url, (f)ile, (e)xtension, (u)ncompress (f)unction
download:{[b;f;e;uf]
 if[0h=type f;:.z.s[b;;e;uf] each f];
 if[l~key l:`$":",f;:l];                          / local file exists
 if[()~key z:`$":",f,e;z 1: .Q.hg`$":",0N!b,f,e]; / download
 if[count uf;system 0N!uf," ",f,e];               / uncompress
 l}

/ load http://yann.lecun.com/exdb/mnist/ dataset
mnist:{
 d:first (1#4;1#"i") 1: 4_(h:4*1+x 3)#x;
 x:d#$[0>i:x[2]-0x0b;::;first ((2 4 4 8;"hief")@\:i,()) 1:] h _x;
 x}

/ load http://etlcdb.db.aist.go.jp/etlcdb/data/ETL9B dataset
etl9b:{(2 1 1 4 504, 64#1;"hxxs*",64#" ") 1: x}

/ general utilities

/ throw verbose exception if x <> y
assert:{if[not x~y;'`$"expecting '",(-3!x),"' but found '",(-3!y),"'"]}

/ generate a range of values between (s)tart and (e)nd with step-size (w)
rng:{[w;s;e]s+w*til 1+floor 1e-14+(e-s)%w}

/ round y to nearest x
rnd:{x*"j"$y%x}

/ allocate x into n bins
binify:{[n;x](n-1)&floor n*.5^x%max x-:min x}

/ divide range ((s)tart;(e)nd) into n bins
nbin:{[n;s;e]s+til[1+n]*(e-s)%n}

/ table x cross y
tcross:{value flip ([]x) cross ([]y)}

/ return memory (used;allocated;max)
/ returned in units specified by x (0:B;1:KB;2:MB;3:GB;...)
mem:{(3#system"w")%x (1024*)/ 1}

/ given a dictionary representing results of the group operator, return the
/ original ungrouped list.  generate the dictionary key if none provided
ugrp:{
 if[not type x;x:til[count x]!x];
 x:@[sum[count each x]#k;value x;:;k:key x];
 x}

/ append a total row and (c)olumn to (t)able
totals:{[c;t]
 t[key[t]0N]:sum value t;
 t:t,'flip (1#c)!enlist sum each value t;
 t}

/ surround a (s)tring or list of stings with a box of (c)haracters
box:{[c;s]
 if[type s;s:enlist s];
 m:max count each s;
 h:enlist (m+2*1+count c)#c;
 s:(c," "),/:(m$/:s),\:(" ",c);
 s:h,s,h;
 s}

/ use (w)eight vector or dictionary to partition (x).  (s)ampling (f)unction:
/ til = no shuffle, 0N? = shuffle, () or ([]) = stratify
part:{[w;sf;x]
 if[99h=type w;:key[w]!.z.s[value w;sf;x]];
 if[99h<type sf;:x (floor sums n*prev[0f;w%sum w]) _ sf n:count x];
 x@:raze each flip value .z.s[w;0N?] each group sf; / stratify
 x}

/ one-hot encode vector, (symbol columns of) table or (non-key symbol
/ columns of) keyed table x.
onehot:{
 if[98h>t:type x;:u!x=/:u:distinct x];       / vector
 if[99h=t;:key[x]!.z.s value x];             / keyed table
 D:.z.s each x c:where 11h=type each flip x; / list of dictionaries
 D:string[c] {(`$(x,"_"),/:string key y)!value y}' D; / rename uniquely
 x:c _ x,' flip raze D;                               / append to table
 x}

/ confusion matrix
cm:{
 n:count u:asc distinct x,y;
 m:./[(n;n)#0;flip (u?y;u?x);1+];
 t:([]x:u)!flip (`$string u)!m;
 t}

/ heckbert's axis label algorithm

/ use heckbert's values to (r)ou(nd) or floor (x) to the nearest nice number
nicenum:{[rnd;x]
 s:`s#$[rnd;0 1.5 3 7;0f,1e-15+1 2 5f]!1 2 5 10f;
 x:f * s x%f:10 xexp floor 10 xlog x;
 x}

/ given requested (n)umber of labels and the (m)i(n) and (m)a(x) values, use
/ heckbert's algorithm to generate a series of nice numbers
heckbert:{[n;mn;mx]
 r:nicenum[0b] mx-mn;           / range of values
 s:nicenum[1b] r%n-1;           / step size
 mn:s*floor mn%s;               / new min
 mx:s*ceiling mx%s;             / new max
 l:rng[s;mn;mx];                / labels
 l}

/ plotting utilities

/ cut m x n matrix X into (x;y;z) where x and y are the indices for X
/ and z is the value stored in X[x;y] - result used to plot heatmaps
hmap:{[X]@[;0;`s#]tcross[til count X;reverse til count X 0],enlist raze X}

/ using (a)ggregation (f)unction, plot (X) using (c)haracters limited to
/ (w)idth and (h)eight. X can be x, (x;y), or (x;y;z)
plot:{[w;h;c;af;X]
 if[type X;X:enlist X];               / promote vector to matrix
 if[1=count X;X:(til count X 0;X 0)]; / turn ,x into (x;y)
 if[2=count X;X,:count[X 0]#1];       / turn (x;y) into (x;y;z)
 if[not `s=attr X 0;c:1_c];           / remove space unless heatmap
 l:heckbert[h div 2].(min;max)@\:X 1; / generate labels
 x:-1_nbin[w] . (min;max)@\:X 0;      / compute x axis
 y:-1_nbin[h] . (first;last)@\:l;     / compute y axis
 Z:(y;x) bin' "f"$X 1 0;              / allocate (x;y) to (w;h) bins
 Z:af each X[2]group flip Z;          / aggregating overlapping z
 Z:c binify[count c;0f^Z];            / map values to characters
 p:./[(h;w)#" ";key Z;:;value Z];     / plot points
 k:@[count[y]#0n;0|y bin l;:;l];      / generate key
 p:reverse k!p;                       / generate plot
 p}

c10:" .-:=+x#%@"                         / 10 characters
c16:" .-:=+*xoXO#$&%@"                   / 16 characters
c68:" .'`^,:;Il!i><~+_-?][}{1)(|/tfjrxn" / 68 characters
c68,:"uvczXYUJCLQ0OZmwqpdbkhao*#MW&8%B@$"

plt:plot[19;10;c10;avg]         / default plot function

/ generate unicode sparkline
spark:raze("c"$226 150,/:129+til 8)binify[8]::

/ image manipulation utilities

/ remove gamma compression
gexpand:{?[x>0.0405;((.055+x)%1.055) xexp 2.4;x%12.92]}
/ add gamma compression
gcompress:{?[x>.0031308;-.055+1.055*x xexp 1%2.4;x*12.92]}

/ convert rgb to grayscale
grayscale:.2126 .7152 .0722 wsum

/ create netpbm bitmap using ascii (or (b)inary) characters for matrix x
pbm:{[b;X]
 s:($[b;"P4";"P1"];-3!count'[(X;X 0)]);
 s,:$[b;enlist"c"$raze((0b sv 8#)each 8 cut raze::)each flip X;" "0:"b"$X];
 s}

/ create netpbm graymap using ascii (or (b)inary) characters for matrix x
pgm:{[b;mx;X]
 if[b;if[255<mx|max (max') X;'`limit]] / binary version has 255 max
 s:($[b;"P5";"P2"];-3!count'[(X;X 0)];string mx);
 s,:$[b;enlist "c"$raze flip X;" "0:"h"$X];
 s}

/ create netpbm pixmap using ascii (or (b)inary) characters for matrix x
ppm:{[b;mx;X]
 if[b;if[255<mx|max (max') (max'') X;'`limit]] / binary version has 255 max
 s:($[b;"P6";"P3"];-3!count'[(X;X 0)];string mx);
 s,:$[b;enlist "c"$2 raze/flip X;" "0:raze flip each "h"$X];
 s}

/ text utilities

/ remove byte order mark if it exists
rbom:{$["\357\273\277"~3#x[0];@[x;0;3_];x]}

/ clean (s)tring of non ascii characters
cleanstr:{[s]
 s:ssr[s;"\342\200[\234\235]";"\""];            / replace double quotes
 s:ssr[s;"\342\200[\231\230]";"'"];             / replace single quotes
 s:ssr[s;"\342\200\246";"..."];                 / replace ellipses
 s:ssr[s;"\342\200\223";"--"];                  / replace endash
 s:ssr[s;"\342\200\224";"---"];                 / replace emdash
 s:ssr[s;"\302\222";"'"];                       / replace single quotes
 s:ssr[s;"\302\241";"!"];                       / replace !
 s:ssr[s;"\302\243";"$"];                       / replace pound symbol with $
 s:ssr[s;"\302\260";"o"];                       / replace o
 s:ssr[s;"\302\262";"^2"];                      / replace ^2
 s:ssr[s;"\302\263";"^3"];                      / replace ^3
 s:ssr[s;"\302\267";"-"];                       / replace -
 s:ssr[s;"\302\274";"1/4"];                     / replace 1/4
 s:ssr[s;"\302\275";"1/2"];                     / replace 1/2
 s:ssr[s;"\302\276";"3/4"];                     / replace 3/4
 s:ssr[s;"\302\277";"?"];                       / replace ?
 s:ssr[s;"\303[\200\201\202\203\204\205]";"A"]; / replace A
 s:ssr[s;"\303\206";"AE"];                      / replace AE
 s:ssr[s;"\303\207";"C"];                       / replace C
 s:ssr[s;"\303[\210\211\212\213]";"E"];         / replace E
 s:ssr[s;"\303[\214\215\216\217]";"I"];         / replace I
 s:ssr[s;"\303\220";"D"];                       / replace D
 s:ssr[s;"\303\221";"N"];                       / replace N
 s:ssr[s;"\303[\222\223\224\225\226\230]";"O"]; / replace O
 s:ssr[s;"\303[\231\232\233\234]";"U"];         / replace U
 s:ssr[s;"\303\235";"Y"];                       / replace y
 s:ssr[s;"\303\237";"s"];                       / replace s
 s:ssr[s;"\303[\240\241\242\243\244\245]";"a"]; / replace a
 s:ssr[s;"\303\246";"ae"];                      / replace ae
 s:ssr[s;"\303\247";"c"];                       / replace c
 s:ssr[s;"\303[\250\251\252\253]";"e"];         / replace e
 s:ssr[s;"\303[\254\255\256\257]";"i"];         / replace i
 s:ssr[s;"\303\260";"d"];                       / replace d
 s:ssr[s;"\303\261";"n"];                       / replace n
 s:ssr[s;"\303[\262\263\264\265\266\270]";"o"]; / replace o
 s:ssr[s;"\303[\271\272\273\274]";"u"];         / replace u
 s:ssr[s;"\303\275";"y"];                       / replace y
 s:ssr[s;"&lt;";"<"];                           / replace <
 s:ssr[s;"&gt;";">"];                           / replace >
 s:ssr[s;"&amp;";"&"];                          / replace &
 s}

/ strip (s)tring of puntuation marks
stripstr:{[s]
 s:ssr[s;"[][\n\\/()<>@#$%^&*=_+.,;:!?-]";" "]; / replace with white space
 s:ssr[s;"['\"0-9]";""];            / delete altogether
 s}
