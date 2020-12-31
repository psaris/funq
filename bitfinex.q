bitfinex.p:string `daily`hourly`minutely!`d`1h`minute
bitfinex.c:string `BTCUSD`ETHUSD`LTCUSD`AIDUSD`BATUSD`DAIUSD`DASHUSD
bitfinex.c,:string `EDOUSD`EOSUSD`ETCUSD`ETPUSD`NEOUSD`OMGUSD`QTUMUSD
bitfinex.c,:string `REPUSD`TRXUSD`XLMUSD`XMRUSD`XVGUSD
bitfinex.c,:string `BTCEUR`ETHEUR`EOSEUR`NEOEUR`TRXEUR`XLMEUR`XVGEUR
bitfinex.c,:string `BTCGBP`ETHGBP`EOSGBP`NEOGBP`TRXGBP`XLMGBP`XVGGBP
bitfinex.c,:string `BTCJPY`ETHJPY`EOSJPY`NEOJPY`TRXJPY`XLMJPY`XVGJPY
bitfinex.c,:string `ETHBTC`LTCBTC`XRPBTC`DAIBTC`DASHBTC
bitfinex.c,:string `EOSBTC`OMGBTC`REPBTC`TRXBTC`XMRBTC
bitfinex.f:bitfinex.p {"_" sv ("Bitfinex";y;x,".csv")}/:\: asc bitfinex.c
bitfinex.b:"http://www.cryptodatadownload.com/cdd/"
-1"[down]loading bitfinex data set";
.ut.download[bitfinex.b;;"";""] each raze bitfinex.f;
.bitfinex.load:{[f]
 if[not count t:("* *FFFF F";1#",") 0: 1_read0 f;:()];
 t:`time`sym`open`high`low`close`qty xcol t;
 t:update time:"P"$?[12>count each time;time;-3_/:time] from t;
 t:update sym:`$sym except\: "/" from t;
 t:`sym xcols 0!select by time from t; / remove duplicates
 t}
bitfinex,:({update `p#sym from x} raze .bitfinex.load peach::)'[`$bitfinex.f]
