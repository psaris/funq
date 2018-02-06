\l util.q
\l ml.q
\l fmincg.q

/ trying to load qml and use its matrix operations
@[system each;("l qml.q";"l qmlmm.q");0N!]; / use qml mm (if available)
@[system each;("l svm.q";"l linear.q");0N!]; / load libsvm,liblinear (if available)
