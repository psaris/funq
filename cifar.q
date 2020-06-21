/ http://www.cs.toronto.edu/~kriz/cifar.html
cifar.f:"cifar-10-binary"
cifar.b:"http://www.cs.toronto.edu/~kriz/"
-1"[down]loading CFAR-10 data set";
.ut.download[cifar.b;;".tar.gz";.ut.untar] cifar.f;
cifar.d:"cifar-10-batches-bin/"
-1"reading labels";
cifar.labels:`$10#read0`$cifar.d,"batches.meta.txt"
cifar.n:5 / how many batches of pictures to load (1-5)
cifar.c:"data_batch_",/:(cifar.n#1_.Q.n),\:".bin"
cifar.parse:(3073#"x";3073#1) 1:
-1"reading images for ",string[cifar.n], " dataset(s)";
cifar.YX:(,'/) cifar.parse each `$cifar.d,/:cifar.c
cifar.y:first cifar.Y:"h"$1#cifar.YX
cifar.X:"f"$1_cifar.YX
cifar_:`YX
-1"reading test image dataset";
cifar.YXt:cifar.parse `$cifar.d,"test_batch.bin"
cifar.yt:first cifar.Yt:"h"$1#cifar.YXt
cifar.Xt:"f"$1_cifar.YXt
cifar_:`YXt
