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

libsvm:
	wget https://github.com/cjlin1/libsvm/archive/v322.tar.gz  -O - | tar -xvf - && mv libsvm-322 libsvm
#	wget https://github.com/psaris/libsvm/archive/master.tar.gz -O - | tar -xvf -

liblinear:
#	wget https://github.com/cjlin1/liblinear/archive/v211.tar.gz  -O - | tar -xvf - && mv liblinear-211 liblinear
	wget https://github.com/psaris/liblinear/archive/master.tar.gz -O - | tar -xvf -&& mv liblinear-master liblinear

libsvm/svm.o: | libsvm
	$(MAKE) -e -C $(dir $@) $(notdir $@)
libsvm/svm-train: | libsvm
	$(MAKE) -e -C $(dir $@) $(notdir $@)
liblinear/linear.o: | liblinear
	$(MAKE) -e -C $(dir $@) $(notdir $@)
liblinear/tron.o: | liblinear
	$(MAKE) -e -C $(dir $@) $(notdir $@)
liblinear/blas/blas.a: | liblinear
	$(MAKE) -e -C $(dir $@) blas
liblinear/train: liblinear/blas/blas.a
	$(MAKE) -e -C $(dir $@) $(notdir $@)



libsvm/svm.h: | libsvm
liblinear/linear.h: | liblinear

%.o: %.c k.h libsvm/svm.h liblinear/linear.h
	$(CC) $(CFLAGS) -I . -I libsvm -I liblinear -c -o $@ $<

libsvm.so: svm.o libsvm/svm.o
	$(CC) $(CFLAGS) $(LDFLAGS),$@ $^ -o $@

liblinear.so: linear.o liblinear/linear.o liblinear/tron.o liblinear/blas/blas.a
	$(CC) $(CFLAGS) $(LDFLAGS),$@ $^ -o $@

lib: libsvm.so liblinear.so

install: lib
	install libsvm.so liblinear.so $(QHOME)/$(QARCH)
	install svm.q linear.q $(QHOME)

libsvm/heart_scale.model: libsvm/svm-train
	cd libsvm && ./svm-train heart_scale
liblinear/heart_scale.model: liblinear/train
	cd liblinear && ./train heart_scale

test-svm: install libsvm/heart_scale.model
	cd libsvm && q ../testsvm.q < /dev/null
test-linear: install liblinear/heart_scale.model
	cd liblinear && q ../testlinear.q < /dev/null
test: test-svm test-linear

clean:
	$(MAKE) -C libsvm clean
	$(MAKE) -C liblinear clean
	rm -f *.so *.o

nuke: clean
	rm -rf k.h libsvm liblinear
