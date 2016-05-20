\d .plot
nbin:{(til[y]%y) bin 0f^x%max x-:min x} / allocate x into y bins
nrng:{[n;s;e]s+til[1+n]*(e-s)%n}  / divide range (s;e) into n buckets
/ cut mxn matrix into (x;y;z) for use by plot
hmap:{(flip (til count x) cross reverse til count first x),enlist raze x}
/ plot X using (c)haracters limited to (w)idth and (h)eight
/ X can be x, (x;y) or (x;y;z)
plot:{[w;h;c;X]
 cn:count c,:();                      / allow a single character
 if[0h<type X;X:enlist X];            / promote vector to matrix
 if[1=count X;X:(til count X 0;X 0)]; / turn ,x into (x;y)
 if[2=count X;X,:count[X 0]#1];       / turn (x;y) into (x;y;z)
 Z:@[X;0 1;nbin;(w;h)];               / allocate (x;y) to (w;h) bins
 Z:flip key[Z],'sum each value Z:Z[2]g:group flip 2#Z; / sum overlapping z
 Z:@[Z;2;nbin;cn];                                     / binify z
 p:h#enlist w#" ";                                     / empty canvas
 p:.[;;:;]/[p;flip Z 1 0;c Z 2];                       / plot points
 k:nrng[h-1] . (min;max)@\:X 1;                        / compute key
 p:reverse k!p;                                        / generate plot
 p}

c10:" .:-=+*#%@"          / http://paulbourke.net/dataformats/asciiart
c10:" .-:=+x#%@"          / 10 characters
c16:" .-:=+*xoXO#$&%@"    / 16 characters
c68:" .'`^,:;Il!i><~+_-?][}{1)(|/tfjrxnuvczXYUJCLQ0OZmwqpdbkhao*#MW&8%B@$"
c89:" `-.'_:,=^;<+!*?/cLzrs7TivJtC{3F)Il(xZfY5S2eajo14[nuyE]P6V9kXpKwGhqAUbOd8#HRDB0$mgMW&Q%N@"
plt:plot[59;30;1_c16]               / default plot function

\
\c 50 100
plt:.plot.plot[59;30;1_.plot.c16]
\cd /Users/nick/Documents/qtips/
\l /Users/nick/Documents/qtips/qtips.q
plt 100*.sim.path[.2;.02] .util.rng[1;2000.01.01;2001.01.01]%365.25
plt .stat.bm 10000?/:1 1f

s:("J"$" " vs) each 1_read0 `:/Users/nick/Documents/plot/nick.pgm
s:reverse[s[0]] # raze 2_ s
value .plot.plot[59;30;reverse .plot.c16] .plot.hmap flip s

plt (log 100000?1f;100000?1f)
.plot.plot[29;15;.plot.c16] .plot.hmap flip 15 cut til 15*15
.plot.plot[29;15;.plot.c89] (x;y;(y:100000?1f)+x:100000?1f)


subset:{x .util.rng[1] . "i"$count[x]*((min;max)@\:"i"$z)%y}
\c 500 500
plt:.plot.plot[99;50;.plot.c10]
plt:.plot.plot[99;50;.plot.c16]
plt:.plot.plot[59;30;.plot.c89]
plt:.plot.plot[59;30;subset[.plot.c89;255] raze s]
plt:.plot.plot[239;120;reverse .plot.c89]


plt:.plot.plot[29;15;reverse .plot.c16]
value plt .plot.hmap flip s
