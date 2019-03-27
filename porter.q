/ this is the porter stemmer algorithm ported to q.  it follows the
/ algorithm presented in:

/ Porter, 1980, An algorithm for suffix stripping, Program, Vol. 14,
/ no. 3, pp 130-137

/ https://tartarus.org/martin/PorterStemmer/def.txt

/ this implementation includes the three points of departure from the
/ original paper introduced here:

/ https://www.tartarus.org/~martin/PorterStemmer

/ note that this implementation stems single words - not full text.
/ this obviates global variables and .porter.stem, therefore, can be
/ 'peach'ed.  instead of run-time computations and function calls,
/ hard-coded offsets and $[;;] operators are used for performance.
/ implementation accuracy can be verified by running the trailing code

/ nick psaris
/ release 1: august 2018

\d .porter

/ are the letters in x vowels
vowel:{
  v:x in "aeiou";  / aeiou are vowels
 / y is a vowel if the preceding letter is a consonant
 v[i where not (1b,v) i:where x="y"]:1b;
 v}

/ are the letters in x consonants
cons:{not vowel x}

/ returns true if x contains a vowel
hasvowel:{any vowel x}

/ returns true if x ends in a double consonant
doublec:{$[2>count x;0b;(=) . -2#x;last cons x;0b]}

/ return true if last three letters are consontant - vowel -
/ consontant and last letter is not in "wxy"
cvc:{$[3>count x;0b;101b~-3#cons x;not last[x] in "wxy";0b]}

/ if a<m replace n charaters with (r)eplacement suffix
r:{[a;n;r;x]$[a<m n:n _ x;n,r;x]}

/ compute m where m in c?(vc){m}v? and c and v are consecutive lists
/ of consontants and vowels
m:{sum[x] - first x:x where differ x:cons x}

/ remove plurals and -ed or -ing
step1ab:{
 x:$[not x like "*s";x;x like "*sses";-2_x;x like "*ies";-2_x;x like "*ss";x;-1_x];
 if[x like "*eed";:$[0<m -3_x;-1_x;x]];
 if[not x like o:"*ed";if[not x like o:"*ing";:x]];
 if[not hasvowel n:(1+neg count o)_x;:x];x:n;
 if[x like "*at";:x,"e"];
 if[x like "*bl";:x,"e"];
 if[x like "*iz";:x,"e"];
 if[doublec x;:$[last[x] in "lsz";x;-1_x]];
 if[1=m x;if[cvc x;:x,"e"]];
 x}

/ replace y with i when there exist other vowels
step1c:{if[x like "*y";if[hasvowel -1_x;x[-1+count x]:"i"]];x}

/ map double suffices to single ones
step2:{
 c:x -2+count x;
 if[c="a";:$[x like "*ational";r[0;-7;"ate";x];x like "*tional";r[0;-6;"tion";x];x]];
 if[c="c";:$[x like "*enci";r[0;-4;"ence";x];x like "*anci";r[0;-4;"ance";x];x]];
 if[c="e";:$[x like "*izer";r[0;-4;"ize";x];x]];
 if[c="l";:$[x like "*bli";r[0;-3;"ble";x];x like "*alli";r[0;-4;"al";x];
   x like "*entli";r[0;-5;"ent";x];x like "*eli";r[0;-3;"e";x];
   x like "*ousli";r[0;-5;"ous";x];x]];
 if[c="o";:$[x like "*ization";r[0;-7;"ize";x];x like "*ation";r[0;-5;"ate";x];
   x like "*ator";r[0;-4;"ate";x];x]];
 if[c="s";:$[x like "*alism";r[0;-5;"al";x];x like "*iveness";r[0;-7;"ive";x];
   x like "*fulness";r[0;-7;"ful";x];x like "*ousness";r[0;-7;"ous";x];x]];
 if[c="t";:$[x like "*aliti";r[0;-5;"al";x];x like "*iviti";r[0;-5;"ive";x];
   x like "*biliti";r[0;-6;"ble";x];x]];
 if[c="g";:$[x like "*logi";r[0;-4;"log";x];x]];
 x}

/ handle -ic-, -full, -ness etc
step3:{
 c:x -1+count x;
 if[c="e";:$[x like "*icate";r[0;-5;"ic";x];x like "*ative";r[0;-5;"";x];
   x like "*alize";r[0;-5;"al";x];x]];
 if[c="i";:$[x like "*iciti";r[0;-5;"ic";x];x]];
 if[c="l";:$[x like "*ical";r[0;-4;"ic";x];x like "*ful";r[0;-3;"";x];x]];
 if[c="s";:$[x like "*ness";r[0;-4;"";x];x]];
 x}

/ remove -ant, -ence etc, in context <c>vcvc<v>
step4:{
 c:x -2+count x;
 if[c="a";:$[x like "*al";r[1;-2;"";x];x]];
 if[c="c";:$[x like "*ance";r[1;-4;"";x];x like "*ence";r[1;-4;"";x];x]];
 if[c="e";:$[x like "*er";r[1;-2;"";x];x]];
 if[c="i";:$[x like "*ic";r[1;-2;"";x];x]];
 if[c="l";:$[x like "*able";r[1;-4;"";x];x like "*ible";r[1;-4;"";x];x]];
 if[c="n";:$[x like "*ant";r[1;-3;"";x];x like "*ement";r[1;-5;"";x];
   x like "*ment";r[1;-4;"";x];x like "*ent";r[1;-3;"";x];x]];
 if[c="o";:$[x like "*ion";$[x[-4+count x] in "st";r[1;-3;"";x];x];
   x like "*ou";r[1;-2;"";x];x]];
 if[c="s";:$[x like "*ism";r[1;-3;"";x];x]];
 if[c="t";:$[x like "*ate";r[1;-3;"";x];x like "*iti";r[1;-3;"";x];x]];
 if[c="u";:$[x like "*ous";r[1;-3;"";x];x]];
 if[c="v";:$[x like "*ive";r[1;-3;"";x];x]];
 if[c="z";:$[x like "*ize";r[1;-3;"";x];x]];
 x}

/ remove final e if m>1, change -ll to -l if m>1
step5:{
 if["e"=last x;x:$[0=a:m x;x;1<a;-1_x;not cvc -1_x;-1_x;x]];
 if["l"=last x;if[doublec x;if[1<m x;:-1_x]]];
 x}

stem:{
 if[3>count x;:x];
 x:step1ab x;
 x:step1c x;
 x:step2 x;
 x:step3 x;
 x:step4 x;
 x:step5 x;
 x}
