/ download data
mnist.zf:(
 "train-labels.idx1-ubyte";
 "train-images.idx3-ubyte";
 "t10k-labels.idx1-ubyte";
 "t10k-images.idx3-ubyte")
mnist.f:ssr[;".";"-"] each mnist.zf
mnist.b:"http://yann.lecun.com/exdb/mnist/"
-1"[down]loading handwritten numbers data set";
.util.download[mnist.b;;".gz";.util.gunzip] mnist.f;
/ rename unzipped file to match zipped fil
mnist.zf {[zf;f]if[zfs~key zfs:`$":",zf;system "r ",zf," ",f]}' mnist.f;

mnist.Y:enlist mnist.y:"i"$.util.ldmnist read1 `$mnist.f 0
mnist.X:flip "f"$raze each .util.ldmnist read1 `$mnist.f 1

mnist.Yt:enlist mnist.yt:"i"$.util.ldmnist read1 `$mnist.f 2
mnist.Xt:flip "f"$raze each .util.ldmnist read1 `$mnist.f 3
