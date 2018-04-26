\l util.q
.z.zd:17 2 6
sd:2017.01m                     / start date
ed:2017.10m                     / end date

-1"downloading citibike data";
b:"http://s3.amazonaws.com/tripdata/"
m1:{x+til 1+y-x} . 2014.09 2016.12m
m1:m1 where m1 within (sd;ed)
f1:,[;"-citibike-tripdata"] each string[m1] except\: "."
.util.download[b;;".zip";"unzip -n"] f1;

m2:{x+til 1+y-x} . 2017.01 2017.12m
m2:m2 where m2 within (sd;ed)
f2:,[;"-citibike-tripdata"] each string[m2] except\: "."
.util.download[b;;".csv.zip";"unzip -n"] f2;

/ data since 2018 has an extra column
/ m3:{x+til 1+y-x} . 2018.01m,-1+"m"$.z.D
/ f3:,[;"_citibikenyc_tripdata"] each string[m3] except\: "."
/ -1"downloading citibike data";
/ .util.download[b;;".csv.zip";"unzip -n"] f3;

process:{[month;f]
 -1"parsing ", string f;
 t:.Q.id ("IPPH*EEH*EEISII";1#",") 0: f;
 -1"building stationid table";
 t:lower[cols t] xcol t;
 c:`stationid`latitude`longitude`name;
 s:c xcol `startstationid`startstationlatitude`startstationlongitude`startstationname#t;
 s,:c xcol `endstationid`endstationlatitude`endstationlongitude`endstationname#t;
 -1"splaying stationid";
 .Q.dpft[`:citibike;month;`stationid] `station set 0!select by stationid from s;
 -1"building tripdata table";
 t:update `station!station.stationid?startstationid from t;
 t:update `station!station.stationid?endstationid from t;
 t:delete startstationlongitude,startstationlatitude,startstationname from t;
 t:delete endstationlongitude,endstationlatitude,endstationname from t;
 t:update `gender!gender from t;
 -1"splaying tripdata";
 .Q.dpft[`:citibike;month;`bikeid] `tripdata set t;
 }

R:6371 / radius of earth in km
PI:acos -1
radian:{[deg]deg*PI%180}
haversine:{[lat0;lon0;lat1;lon1]
 a:a*a:sin .5*radian lat1-lat0;
 b:b*b:sin .5*radian lon1-lon0;
 a+:b*cos[radian lat0]*cos[radian lat1];
 d:6371*2f*.qml.atan2[sqrt a;sqrt 1f-a];
 d}

-1"checking if downloads need splaying";
months:m1,m2
files:f1,f2
w:til count files
if[not ()~key `:citibike;system"l citibike";w:where not months in month;system"cd ../"]
if[()~key `:citibike;`:citibike/gender set get `gender set `unknown`male`female]
months[w] process' `$(f1,f2)[w],\:".csv";
-1"loading citibike database";
\l citibike