include ../mk/pkg.mk

libsvm-321.tar.gz.url = https://github.com/cjlin1/libsvm/archive/v321.tar.gz
libsvm-321.tar.gz.sha256 = \
     7f494b23f8a4c9fff2643a0805bbd3dad688854cc488c075ec3909bb346b6685
libsvm-master.tar.gz.url = https://github.com/psaris/libsvm/archive/master.tar.gz

LIBSVM_VER=v321
LIBSVM_VER=master

ifneq ($(BUILD_LIBSVM),)

do_extract: ../download/libsvm-$(LIBSVM_VER).tar.gz
	tar xzf $<
	ln -sf libsvm-$(LIBSVM_VER) work

do_patch: make.patch
	cat $^ | patch -p1 -d work

do_configure:
	echo CFLAGS='$(FLAGS) $(CXXFLAGS)' >> work/Makefile
	echo CXX='$(CXX)' >> work/Makefile

do_build:
	$(MAKE) -C work svm.o svm-train
	cd work && ./svm-train heart_scale

install_libs:
	cp work/svm.o ../lib/libsvm.o

endif # BUILD_LIBSVM


install_libs:
do_install: install_libs
	cp work/svm.h ../include/

do_clean:
	rm -rf libsvm-$(LIBSVM_VER) work
