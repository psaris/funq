ifndef QHOME
$(error QHOME is not set)
endif

OS := $(shell uname)
QARCH ?= $(if $(filter Darwin,$(OS)),m32,l32)
export CFLAGS = -Wall -O3 -fPIC -DKXVER=3 $(if $(filter %32,$(QARCH)),-m32)
LDFLAGS = $(if $(filter Darwin,$(OS)),-bundle -undefined dynamic_lookup -install_name,-shared -Wl,-soname)

all: lib

k.h:
	wget https://kx.com/q/c/c/k.h

libsvm-master:
	wget https://github.com/psaris/libsvm/archive/master.tar.gz -O - | tar -xvf -

liblinear-master:
	wget https://github.com/psaris/liblinear/archive/master.tar.gz -O - | tar -xvf -

libsvm-master/svm.o: | libsvm-master
	$(MAKE) -e -C libsvm-master svm.o
liblinear-master/linear.o: | liblinear-master
	$(MAKE) -e -C liblinear-master linear.o
liblinear-master/tron.o: | liblinear-master
	$(MAKE) -e -C liblinear-master tron.o
liblinear-master/blas/blas.a: | liblinear-master
	$(MAKE) -e -C liblinear-master blas/blas.a


libsvm-master/svm.h: | libsvm-master

liblinear-master/linear.h: | liblinear-master

%.o: %.c k.h libsvm-master/svm.h liblinear-master/linear.h
	$(CC) $(CFLAGS) -I . -I libsvm-master -I liblinear-master -c -o $@ $<

libsvm.so: svm.o libsvm-master/svm.o
	$(CC) $(CFLAGS) $(LDFLAGS),$@ $^ -o $@

liblinear.so: linear.o liblinear-master/linear.o liblinear-master/tron.o liblinear-master/blas/blas.a
	$(CC) $(CFLAGS) $(LDFLAGS),$@ $^ -o $@

lib: libsvm.so liblinear.so

install: lib
	install libsvm.so liblinear.so $(QHOME)/$(QARCH)
	install svm.q linear.q $(QHOME)

libsvm-master/heart_scale.model:
	$(MAKE) -e -C libsvm-master svm-train
	cd libsvm-master && ./svm-train heart_scale
liblinear-master/heart_scale.model:
	$(MAKE) -C liblinear-master train
	cd liblinear-master && ./train heart_scale

test: install libsvm-master/heart_scale.model liblinear-master/heart_scale.model
	cd libsvm-master && q ../testsvm.q < /dev/null
	cd liblinear-master && q ../testlinear.q < /dev/null

clean:
	$(MAKE) -C libsvm-master clean
	$(MAKE) -C liblinear-master clean
	rm -f *.so *.o

nuke: clean
	rm -rf k.h libsvm-master liblinear-master
