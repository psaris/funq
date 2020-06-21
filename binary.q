binary.f:"binary.csv"
binary.b:"https://www.ats.ucla.edu/stat/data/"
-1"[down]loading binary data set";
.ut.download[binary.b;;"";""] binary.f;
binary.t:("BIFI";1#",") 0: `$binary.f
binary[`Y`X]: 0 1 cut "f"$value flip binary.t
