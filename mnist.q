/ download data
mnist.f:(
 "train-labels-idx1-ubyte";
 "train-images-idx3-ubyte";
 "t10k-labels-idx1-ubyte";
 "t10k-images-idx3-ubyte")
mnist.b:"http://yann.lecun.com/exdb/mnist/"
-1"downloading handwritten numbers dataset";
.util.download[mnist.b;;".gz";system 0N!"gunzip -v ",] each mnist.f; / download data

-1"loading training data";
mnist.Y:enlist mnist.y:"i"$.util.ldmnist read1 `$mnist.f 0
mnist.X:flip "f"$raze each .util.ldmnist read1 `$mnist.f 1

