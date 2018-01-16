\d .util

/ box-muller (copied from qtips/stat.q) (m?-n in k6)
bm:{
 if[count[x] mod 2;'`length];
 x:2 0N#x;
 r:sqrt -2f*log first x;
 theta:2f*acos[-1f]*last x;
 x: r*cos theta;
 x,:r*sin theta;
 x}

/ (b)ase url, (f)ile, (e)xtension, (u)nzip (f)unction
download:{[b;f;e;uf]
 if[()~key `$":",f,e;(`$":",f,e) 1: .Q.hg`$":",0N!b,f,e];
 if[()~key `$":",f;uf f,e];
 }

/ load mnist dataset
ldmnist:{
 d:first (1#4;1#"i") 1: 4_(h:4*1+x 3)#x;
 x:d#$[0>i:x[2]-0x0b;::;first ((2 4 4 8;"hief")@\:i,()) 1:] h _x;
 x}

/ load http://etlcdb.db.aist.go.jp/etlcdb/data/ETL9B dataset
etl9b:{(2 1 1 4 504, 64#1;"hxxs*",64#" ") 1: x}

/ remove gamma compression
gexpand:{?[x>0.0405;((.055+x)%1.055) xexp 2.4;x%12.92]}
/ add gamma compression
gcompress:{?[x>.0031308;-.055+1.055*x xexp 1%2.4;x*12.92]}

/ convert rgb to grayscale
grayscale:.2126 .7152 .0722 wsum

/ create netpbm formatted strings for bitmap, grayscale and rgb
pbm:{("P1";" " sv string count'[(x;x 0)])," " 0: "b"$x}
pgm:{("P2";" " sv string count'[(x;x 0)];string "h"$max/[x])," " 0: "h"$x}
ppm:{("P3";" " sv string count'[(x;x 0)];string "h"$max/[x])," " 0: flip raze "h"$x}

/ surround a (s)tring or list of stings with a box of (c)haracters
box:{[c;s]
 if[type s;s:enlist s];
 m:max count each s;
 h:enlist (m+2*1+count c)#c;
 s:(c," "),/:(m$/:s),\:(" ",c);
 s:h,s,h;
 s}

/ append a total row and (c)olumn to (t)able
totals:{[c;t]
 t[key[t]0N]:sum value t;
 t:t,'flip (1#c)!enlist sum each value t;
 t}

/ return memory (used;allocated;max)
/ returned in units specified by x (0:B;1:KB;2:MB;3:GB;...)
mem:{(3#system"w")%x (1024*)/ 1}

/ throw verbose exception if x <> y
assert:{if[not x~y;'`$"expecting '",(-3!x),"' but found '",(-3!y),"'"]}