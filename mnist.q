/ download data
mnist.f:(
 "train-labels-idx1-ubyte";
 "train-images-idx3-ubyte";
 "t10k-labels-idx1-ubyte";
 "t10k-images-idx3-ubyte")
mnist.b:"http://yann.lecun.com/exdb/mnist/"
-1"[down]loading handwritten numbers data set";
.util.download[mnist.b;;".gz";.util.gunzip] mnist.f; / download data

-1"loading mnist training data";
mnist.Y:enlist mnist.y:"i"$.util.ldmnist read1 `$mnist.f 0
mnist.X:flip "f"$raze each .util.ldmnist read1 `$mnist.f 1

-1"loading mnist testing data";
mnist.Yt:enlist mnist.yt:"i"$.util.ldmnist read1 `$mnist.f 2
mnist.Xt:flip "f"$raze each .util.ldmnist read1 `$mnist.f 3

