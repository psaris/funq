uef.s:("s1.txt";"s2.txt";"s3.txt";"s4.txt")
uef.a:("a1.txt";"a2.txt";"a3.txt")
uef.d:("dim032.txt";"dim064.txt";"dim128.txt")
uef.d,:("dim256.txt";"dim512.txt";"dim1024.txt");
uef.b:"http://www.cs.uef.fi/sipu/datasets/"
-1"[down]loading uef data sets";
.util.download[uef.b;;"";""] uef.s,uef.a,uef.d;

uef,:`s1`s2`s3`s4!("JJ";10 10) 0:/: `$uef.s
uef,:`a1`a2`a3!("JJ";8 8) 0:/: `$uef.a
uef,:(!) . flip {(`$"d",string x;(x#"J";x#6) 0: y)}'[16*\6#2;`$uef.d]

