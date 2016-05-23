\d .mnist

ldidx:{
 d:first (1#4;1#"i") 1: 4_(h:4*1+x 3)#x;
 x:$[0>i:x[2]-0x0b;::;first ((2 4 4 8;"hief")@\:i,()) 1:] h _x;
 x:((prd[d])#x){y cut x}/reverse 1_d;
 x}