binary.f:"binary.csv"
binary.b:"https://www.ats.ucla.edu/stat/data/"
-1"[down]loading binary data set";
.util.download[binary.b;;"";""] binary.f;
binary.t:("BIFI";1#",") 0: `$binary.f
binary.Y:"f"$1#value flip binary.t
binary.X:"f"$1_value flip binary.t
