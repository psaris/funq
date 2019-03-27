ifndef QHOME
$(error QHOME is not set)
endif

OS := $(shell uname)
QARCH ?= $(if $(filter Darwin,$(OS)),m32,l32)
Q ?= $(QHOME)/$(QARCH)/q
export CFLAGS = -Wall -O3 -fPIC -DKXVER=3 $(if $(filter %32,$(QARCH)),-m32)
LDFLAGS = $(if $(filter Darwin,$(OS)),-bundle -undefined dynamic_lookup -install_name,-shared -Wl,-soname)

all: lib

k.h:
	wget https://raw.githubusercontent.com/KxSystems/kdb/master/c/c/k.h

libsvm:
	git clone --depth 1 -b v322 https://github.com/cjlin1/libsvm.git

liblinear:
	git clone --depth 1 -b v221 https://github.com/cjlin1/liblinear.git

xgboost:
	git clone --depth 1 -b release_0.72 --recurse-submodules -j8 https://github.com/dmlc/xgboost.git

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
xgboost/lib/libxgboost.dylib: | xgboost
	$(MAKE) -C xgboost lib/libxgboost.dylib



libsvm/svm.h: | libsvm
liblinear/linear.h: | liblinear

%.o: %.c k.h libsvm/svm.h liblinear/linear.h
	$(CC) $(CFLAGS) -I . -I libsvm -I liblinear -c -o $@ $<

libsvm.so: svm.o libsvm/svm.o
	$(CC) $(CFLAGS) $(LDFLAGS),$@ $^ -o $@

liblinear.so: linear.o liblinear/linear.o liblinear/tron.o liblinear/blas/blas.a
	$(CC) $(CFLAGS) $(LDFLAGS),$@ $^ -o $@

lib: libsvm.so liblinear.so xgboost #/lib/libxgboost.dylib


install: lib
	install libsvm.so liblinear.so $(QHOME)/$(QARCH)
	install svm.q linear.q $(QHOME)

libsvm/heart_scale.model: libsvm/svm-train
	cd libsvm && ./svm-train heart_scale
liblinear/heart_scale.model: liblinear/train
	cd liblinear && ./train heart_scale

FUNQFILES += plot.q knn.q kmeans.q em.q pagerank.q sparse.q 
FUNQFILES += decisiontree.q randomforest.q markov.q hca.q cosim.q 
FUNQFILES += adaboost.q linreg.q logreg.q recommend.q nn.q onevsall.q
FUNQFILES += jane.q nb.q tfidf.q
#FUNQFILES += supportvectormachine.q

test-funq:
	set -ex; for f in $(FUNQFILES); do $(Q) $$f -s 4 >/dev/null </dev/null; done

test-svm: install libsvm/heart_scale.model
	cd libsvm && $(Q) ../testsvm.q < /dev/null
test-linear: install liblinear/heart_scale.model
	cd liblinear && $(Q) ../testlinear.q < /dev/null

test: test-funq

ifneq (,$(wildcard $(QHOME)/$(QARCH)/libsvm.so))
test: test-svm
endif

ifneq (,$(wildcard $(QHOME)/$(QARCH)/liblinear.so))
test: test-linear
endif

clean-libsvm: | libsvm
	$(MAKE) -C libsvm clean
clean-liblinear: | liblinear
	$(MAKE) -C liblinear clean
clean-xgboost: | xgboost
	$(MAKE) -C xgboost clean

clean: clean-libsvm clean-liblinear clean-xgboost
	$(RM) *.so *.o

nuke-libsvm:
	$(RM) -r libsvm
nuke-liblinear:
	$(RM) -r liblinear
nuke-xgboost:
	$(RM) -r xgboost

nuke: nuke-libsvm nuke-liblinear nuke-xgboost
	$(RM) *.so *.o k.h
