binance.p:string `daily`hourly`minutely!`d`1h`minute
binance.c:string `BTCUSDT`ETHUSDT`LTCUSDT`NEOUSDT`BNBUSDT`XRPUSDT
binance.c,:string `LINKUSDT`TRXUSDT`ETCUSDT`XLMUSDT`ZECUSDT
binance.c,:string `ADAUSDT`QTUMUSDT`DASHUSDT`XMRUSDT`BTTUSDT
binance.c,:string `ADABTC`ASTBTC`BTGBTC`DASHBTC`EOSBTC`ETCBTC`ETHBTC
binance.c,:string `IOTABTC`LTCBTC`NEOBTC`XMRBTC`XLMBTC`XRPBTC
binance.f:binance.p {"_" sv ("Binance";y;x,".csv")}/:\: asc binance.c
binance.b:"http://www.cryptodatadownload.com/cdd/"
-1"[down]loading binance data set";
.ut.download[binance.b;;"";""] each raze binance.f;
.binance.load:{[f]
 if[not count t:("* *FFFFF I";1#",") 0: 1_read0 f;:()];
 t:`time`sym`open`high`low`close`qty`n xcol t;
 t:update time:"P"$?[12>count each time;time;-3_/:time] from t;
 t:update sym:`$sym except\: "/" from t;
 t:`sym xcols 0!select by time from t; / remove duplicates
 t}
binance,:({update `p#sym from x} raze .binance.load peach::)'[`$binance.f]
