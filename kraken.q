kraken.p:string `daily`hourly`minutely!`d`1h`minute
kraken.c:string `BTCUSD`ETHUSD`LTCUSD`XRPUSD`LINKUSD`BCHUSD
kraken.c,:string `DOTUSD`EOSUSD`ADAUSD`XMRUSD`DASHUSD`ETCUSD
kraken.c,:string `ZECUSD`XTZUSD`TRXUSD`PAXGUSD`COMPUSD
kraken.c,:string `BTCEUR`ETHEUR`LTCEUR`XRPEUR`LINKEUR`BCHEUR
kraken.c,:string `DOTEUR`EOSEUR`ADAEUR`XMREUR`DASHEUR`ETCEUR
kraken.c,:string `ZECEUR`XTZEUR`TRXEUR`PAXGEUR`COMPEUR
kraken.c,:string `ETHBTC`LTCBTC
kraken.f:kraken.p {"_" sv ("Kraken";y;x,".csv")}/:\: asc kraken.c
kraken.b:"http://www.cryptodatadownload.com/cdd/"
-1"[down]loading kraken data set";
.ut.download[kraken.b;;"";""] each raze kraken.f;
.kraken.load:{[f]
 if[not count t:("P *FFFFFF I";1#",") 0: 1_read0 f;:()];
 t:`time`sym`open`high`low`close`vwap`qty`n xcol t;
 t:update sym:`$sym except\: "/" from t;
 t:`sym xcols 0!select by time from t; / remove duplicates
 t}
kraken,:({update `p#sym from x} raze .kraken.load peach::)'[`$kraken.f]
