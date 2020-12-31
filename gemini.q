gemini.p:string `daily`hourly!`day`1hr
gemini.c:string `BTCUSD`ETHUSD`LTCUSD`ETHBTC`ZECUSD`ZECBTC`ZECETH
gemini.f:gemini.p {"_" sv ("gemini";y;x,".csv")}/:\: asc gemini.c
gemini.y:string (`year$.z.D-1) + reverse neg til 3
gemini.f[`minutely]:raze gemini.y {"_" sv ("gemini";y;x;"1min.csv")}\:/: asc gemini.c
gemini.b:"http://www.cryptodatadownload.com/cdd/"
-1"[down]loading gemini data set";
.ut.download[gemini.b;;"";""] each raze gemini.f;
.gemini.load:{[f]
 if[not count t:("* SFFFFF";1#",") 0: 1_read0 f;:()];
 t:`time`sym`open`high`low`close`qty xcol t;
 t:update time:"P"$?[12>count each time;time;-3_/:time] from t;
 t:`sym xcols 0!select by time from t; / remove duplicates
 t}
gemini,:({update `p#sym from x} raze .gemini.load peach::)'[`$gemini.f]
