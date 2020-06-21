\l funq.q

b:"https://tartarus.org/martin/PorterStemmer/"

-1"[down]loading porter stemmer vocabulary";
pin:read0 .ut.download[b;;"";""] "voc.txt"
-1"[down]loading stemmed vocabulary";
pout:read0 .ut.download[b;;"";""] "output.txt"
-1"stemming vocabulary";
out:.porter.stem peach pin
-1"incorrectly stemmed  ";
.ut.assert[0] count flip (pin;pout;out)@\: where not pout ~'out
