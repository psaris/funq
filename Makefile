include ../mk/pkg.mk

liblinear-210.tar.gz.url = https://github.com/cjlin1/liblinear/archive/v210.tar.gz
liblinear-210.tar.gz.sha256 = \
     9e559d1f0714799d4cf7742fb186012459285e25bed9c5847d5d8032daefc8de
liblinear-master.tar.gz.url = https://github.com/psaris/liblinear/archive/master.tar.gz

LIBLINEAR_VER=v210
LIBLINEAR_VER=master

ifneq ($(BUILD_LIBLINEAR),)

do_extract: ../download/liblinear-$(LIBLINEAR_VER).tar.gz
	tar xzf $<
	ln -sf liblinear-$(LIBLINEAR_VER) work

do_patch: make.patch
	cat $^ | patch -p1 -d work

do_configure:
	echo CFLAGS='$(FLAGS) $(CFLAGS)' >> work/Makefile
	echo CXX='$(XCC) -lstdc++' >> work/Makefile
	echo CC='$(XCC)' >> work/Makefile

do_build:
	$(MAKE) -C work linear.o tron.o train
	cd work && ./train heart_scale

install_libs:
	cp work/linear.o ../lib/liblinear.o
	cp work/tron.o ../lib/libtron.o


endif # BUILD_LIBLINEAR


install_libs:
do_install: install_libs
	cp work/linear.h ../include/

do_clean:
	rm -rf liblinear-$(LIBLINEAR_VER) work
