bitstamp.p:string `daily`hourly`minutely!`d`1h`minute
bitstamp.c:string `BTCUSD`ETHUSD`LTCUSD`XRPUSD`BCHUSD
bitstamp.c,:string `BTCEUR`ETHEUR`LTCEUR`BCHEUR
bitstamp.c,:string `ETHBTC`LTCBTC`BCHBTC
bitstamp.f:bitstamp.p {"_" sv ("Bitstamp";y;x,".csv")}/:\: asc bitstamp.c
bitstamp.b:"http://www.cryptodatadownload.com/cdd/"
-1"[down]loading bitstamp data set";
.ut.download[bitstamp.b;;"";""] each raze bitstamp.f;
.bitstamp.load:{[f]
 if[not count t:("P *FFFFF";1#",") 0: 1_read0 f;:()];
 t:`time`sym`open`high`low`close`qty xcol t;
 t:update sym:`$sym except\: "/" from t;
 t:`sym xcols 0!select by time from t; / remove duplicates
 t}
bitstamp,:({update `p#sym from x} raze .bitstamp.load peach::)'[`$bitstamp.f]
