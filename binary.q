binary.f:"binary.csv"
binary.b:"http://www.ats.ucla.edu/stat/data/"
.util.download[binary.b;;"";""] binary.f;
binary.t:("BIFI";1#",") 0: `$binary.f
binary.Y:"f"$1#value flip binary.t
binary.X:"f"$1_value flip binary.t
