zoo.f:"zoo.data"
zoo.b:"https://archive.ics.uci.edu/ml/machine-learning-databases/"
zoo.b,:"zoo/"
-1"[down]loading zoo data set";
.ut.download[zoo.b;;"";""] zoo.f;
zoo.c:`animal`hair`feathers`eggs`milk`airborne`aquatic`predator`toothed
zoo.c,:`backbone`breathes`venomous`fins`legs`tail`domestic`catsize`typ
zoo.typ:``mamal`bird`reptile`fish`amphibian`insect`invertebrate
zoo.t:`typ xcols flip zoo.c!("SBBBBBBBBBBBBHBBBJ";",") 0: `$zoo.f
update `zoo.typ!typ from `zoo.t;
zoo.y:first first zoo[`Y`X]: 0 1 cut value flip[zoo.t] _ `animal
zoo.X:"f"$zoo.X
