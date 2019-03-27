\l funq.q

b:"https://tartarus.org/martin/PorterStemmer/"

-1"downloading porter stemmer vocabulary";
pin:read0 .util.download[b;;"";""] "voc.txt"
-1"downloading stemmed vocabulary";
pout:read0 .util.download[b;;"";""] "output.txt"
-1"stemming vocabulary";
out:.porter.stem peach pin
-1"incorrectly stemmed  ";
.util.assert[0] count flip (pin;pout;out)@\: where not pout ~'out
