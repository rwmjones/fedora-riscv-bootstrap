# Refer to the README file to understand how Fedora on RISC-V is
# bootstrapped.

# Note these are chosen very specifically to ensure the different
# versions work together.  Don't blindly update to the latest
# versions.  See also:
# https://github.com/riscv/riscv-pk/issues/18#issuecomment-206115996
RISCV_QEMU_COMMIT               = 94f5eb73091fb4fe272db3e943f173ecc0f78ffd
RISCV_QEMU_SHORTCOMMIT          = 94f5eb73
RISCV_FESVR_COMMIT              = 0f34d7ad311f78455a674224225f5b3056efba1d
RISCV_FESVR_SHORTCOMMIT         = 0f34d7ad
RISCV_ISA_SIM_COMMIT            = 3bfc00ef2a1b1f0b0472a39a866261b00f67027e
RISCV_ISA_SIM_SHORTCOMMIT       = 3bfc00ef
RISCV_GNU_TOOLCHAIN_COMMIT      = 728afcddcb0526a0f6560c4032da82805f054d58
RISCV_GNU_TOOLCHAIN_SHORTCOMMIT = 728afcdd
RISCV_PK_COMMIT                 = 85ae17aa149b9ea114bdd70cc30ea7e73813fb48
RISCV_PK_SHORTCOMMIT            = 85ae17aa

# For the correct versions, see
# riscv-gnu-toolchain/Makefile.in *_version variables
BINUTILS_VERSION = 2.25.1
GLIBC_VERSION    = 2.22
GCC_VERSION      = 5.3.0
NEWLIB_VERSION   = 2.2.0

# See linux-4.1.y-riscv branch of
# https://github.com/riscv/riscv-linux
KERNEL_VERSION   = 4.1.26

# A local copy of Linux git repo so you don't have to keep downloading
# git commits (optional).
LOCAL_LINUX_GIT_COPY = $(HOME)/d/linux

all: stage1 stage2 stage3 stage4

# Stage 1

stage1: stage1-riscv-qemu/riscv-qemu-$(RISCV_QEMU_SHORTCOMMIT).tar.gz \
	stage1-riscv-qemu/riscv-qemu.spec \
	stamp-riscv-qemu-installed \
	stage1-riscv-fesvr/riscv-fesvr-$(RISCV_FESVR_SHORTCOMMIT).tar.gz \
	stage1-riscv-fesvr/riscv-fesvr.spec \
	stamp-riscv-fesvr-installed \
	stage1-riscv-isa-sim/riscv-isa-sim-$(RISCV_ISA_SIM_SHORTCOMMIT).tar.gz \
	stage1-riscv-isa-sim/riscv-isa-sim.spec \
	stamp-riscv-isa-sim-installed

stage1-riscv-qemu/riscv-qemu-$(RISCV_QEMU_SHORTCOMMIT).tar.gz:
	rm -f $@ $@-t
	wget -O $@-t 'https://github.com/riscv/riscv-qemu/archive/$(RISCV_QEMU_COMMIT)/riscv-qemu-$(RISCV_QEMU_SHORTCOMMIT).tar.gz'
	mv $@-t $@

stage1-riscv-qemu/riscv-qemu.spec: stage1-riscv-qemu/riscv-qemu.spec.in
	sed -e 's/@COMMIT@/$(RISCV_QEMU_COMMIT)/g' \
	    -e 's/@SHORTCOMMIT@/$(RISCV_QEMU_SHORTCOMMIT)/g' \
	    < $^ > $@-t
	mv $@-t $@

stamp-riscv-qemu-installed:
	rm -f $@
	@rpm -q riscv-qemu >/dev/null || { \
	  echo "ERROR: You must install riscv-qemu:"; \
	  echo; \
	  echo "       dnf copr enable rjones/riscv"; \
	  echo "       dnf install riscv-qemu"; \
	  echo; \
	  echo "OR: you can build it yourself from the stage1-riscv-qemu directory."; \
	  echo; \
	  exit 1; \
	}
	@qemu-system-riscv --version || { \
	  echo "ERROR: qemu-system-riscv is not working."; \
	  echo "Make sure you installed the riscv-qemu package."; \
	  exit 1; \
	}
	touch $@

stage1-riscv-fesvr/riscv-fesvr-$(RISCV_FESVR_SHORTCOMMIT).tar.gz:
	rm -f $@ $@-t
	wget -O $@-t 'https://github.com/riscv/riscv-fesvr/archive/$(RISCV_FESVR_COMMIT)/riscv-fesvr-$(RISCV_FESVR_SHORTCOMMIT).tar.gz'
	mv $@-t $@

stage1-riscv-fesvr/riscv-fesvr.spec: stage1-riscv-fesvr/riscv-fesvr.spec.in
	sed -e 's/@COMMIT@/$(RISCV_FESVR_COMMIT)/g' \
	    -e 's/@SHORTCOMMIT@/$(RISCV_FESVR_SHORTCOMMIT)/g' \
	    < $^ > $@-t
	mv $@-t $@

stamp-riscv-fesvr-installed:
	rm -f $@
	@rpm -q riscv-fesvr >/dev/null || { \
	  echo "ERROR: You must install riscv-fesvr:"; \
	  echo; \
	  echo "       dnf copr enable rjones/riscv"; \
	  echo "       dnf install riscv-fesvr"; \
	  echo; \
	  echo "OR: you can build it yourself from the stage1-riscv-fesvr directory."; \
	  echo; \
	  exit 1; \
	}
	touch $@

stage1-riscv-isa-sim/riscv-isa-sim-$(RISCV_ISA_SIM_SHORTCOMMIT).tar.gz:
	rm -f $@ $@-t
	wget -O $@-t 'https://github.com/riscv/riscv-isa-sim/archive/$(RISCV_ISA_SIM_COMMIT)/riscv-isa-sim-$(RISCV_ISA_SIM_SHORTCOMMIT).tar.gz'
	mv $@-t $@

stage1-riscv-isa-sim/riscv-isa-sim.spec: stage1-riscv-isa-sim/riscv-isa-sim.spec.in
	sed -e 's/@COMMIT@/$(RISCV_ISA_SIM_COMMIT)/g' \
	    -e 's/@SHORTCOMMIT@/$(RISCV_ISA_SIM_SHORTCOMMIT)/g' \
	    < $^ > $@-t
	mv $@-t $@

stamp-riscv-isa-sim-installed:
	rm -f $@
	@rpm -q riscv-isa-sim >/dev/null || { \
	  echo "ERROR: You must install riscv-isa-sim:"; \
	  echo; \
	  echo "       dnf copr enable rjones/riscv"; \
	  echo "       dnf install riscv-isa-sim"; \
	  echo; \
	  echo "OR: you can build it yourself from the stage1-riscv-isa-sim directory."; \
	  echo; \
	  exit 1; \
	}
	touch $@

# Stage 2

stage2: stage2-riscv-gnu-toolchain/riscv-gnu-toolchain-$(RISCV_GNU_TOOLCHAIN_SHORTCOMMIT).tar.gz \
	stage2-riscv-gnu-toolchain/binutils-$(BINUTILS_VERSION).tar.gz \
	stage2-riscv-gnu-toolchain/gcc-$(GCC_VERSION).tar.gz \
	stage2-riscv-gnu-toolchain/glibc-$(GLIBC_VERSION).tar.gz \
	stage2-riscv-gnu-toolchain/newlib-$(NEWLIB_VERSION).tar.gz \
	stage2-riscv-gnu-toolchain/riscv-gnu-toolchain.spec \
	stamp-riscv-gnu-toolchain-installed \
	stage2-riscv-pk/riscv-pk-$(RISCV_PK_SHORTCOMMIT).tar.gz \
	stage2-riscv-pk/riscv-pk.spec \
	stamp-riscv-pk-installed

stage2-riscv-gnu-toolchain/riscv-gnu-toolchain-$(RISCV_GNU_TOOLCHAIN_SHORTCOMMIT).tar.gz:
	rm -f $@ $@-t
	wget -O $@-t https://github.com/lowRISC/riscv-gnu-toolchain/archive/$(RISCV_GNU_TOOLCHAIN_COMMIT)/riscv-gnu-toolchain-$(RISCV_GNU_TOOLCHAIN_SHORTCOMMIT).tar.gz
	mv $@-t $@

stage2-riscv-gnu-toolchain/binutils-$(BINUTILS_VERSION).tar.gz:
	rm -f $@ $@-t
	wget -O $@-t http://mirrors.kernel.org/gnu/binutils/binutils-$(BINUTILS_VERSION).tar.gz
	mv $@-t $@

# GCC 5 no longer compiles with GCC 6 unless we patch it.
# https://gcc.gnu.org/bugzilla/show_bug.cgi?id=69959
stage2-riscv-gnu-toolchain/gcc-$(GCC_VERSION).tar.gz:
	rm -f $@ $@-t
	wget -O $@-t http://mirrors.kernel.org/gnu/gcc/gcc-$(GCC_VERSION)/gcc-$(GCC_VERSION).tar.gz
	zcat $@-t | tar xf -
	cd gcc-$(GCC_VERSION) && patch -p0 < ../stage2-riscv-gnu-toolchain/gcc-5-fix-compilation-with-gcc-6.patch
	tar zcf $@-t gcc-$(GCC_VERSION)
	rm -r gcc-$(GCC_VERSION)
	mv $@-t $@

stage2-riscv-gnu-toolchain/glibc-$(GLIBC_VERSION).tar.gz:
	rm -f $@ $@-t
	wget -O $@-t http://mirrors.kernel.org/gnu/glibc/glibc-$(GLIBC_VERSION).tar.gz
	mv $@-t $@

stage2-riscv-gnu-toolchain/newlib-$(NEWLIB_VERSION).tar.gz:
	rm -f $@ $@-t
	wget -O $@-t ftp://sourceware.org/pub/newlib/newlib-$(NEWLIB_VERSION).tar.gz
	mv $@-t $@

stage2-riscv-gnu-toolchain/riscv-gnu-toolchain.spec: stage2-riscv-gnu-toolchain/riscv-gnu-toolchain.spec.in
	sed -e 's/@COMMIT@/$(RISCV_GNU_TOOLCHAIN_COMMIT)/g' \
	    -e 's/@SHORTCOMMIT@/$(RISCV_GNU_TOOLCHAIN_SHORTCOMMIT)/g' \
	    -e 's/@BINUTILS_VERSION@/$(BINUTILS_VERSION)/g' \
	    -e 's/@GCC_VERSION@/$(GCC_VERSION)/g' \
	    -e 's/@GLIBC_VERSION@/$(GLIBC_VERSION)/g' \
	    -e 's/@NEWLIB_VERSION@/$(NEWLIB_VERSION)/g' \
	    < $^ > $@-t
	mv $@-t $@

stamp-riscv-gnu-toolchain-installed:
	rm -f $@
	@rpm -q riscv-gnu-toolchain >/dev/null || { \
	  echo "ERROR: You must install riscv-gnu-toolchain:"; \
	  echo; \
	  echo "       dnf copr enable rjones/riscv"; \
	  echo "       dnf install riscv-gnu-toolchain"; \
	  echo; \
	  echo "OR: you can build it yourself from the stage2-riscv-gnu-toolchain directory."; \
	  echo; \
	  exit 1; \
	}
	@riscv64-unknown-elf-gcc --version || { \
	  echo "ERROR: riscv64-unknown-elf-gcc (cross compiler) is not working."; \
	  echo "Make sure you installed the riscv-gnu-toolchain package."; \
	  exit 1; \
	}
	touch $@

stage2-riscv-pk/riscv-pk-$(RISCV_PK_SHORTCOMMIT).tar.gz:
	rm -f $@ $@-t
	wget -O $@-t https://github.com/lowRISC/riscv-pk/archive/$(RISCV_PK_COMMIT)/riscv-pk-$(RISCV_PK_SHORTCOMMIT).tar.gz
	mv $@-t $@

stage2-riscv-pk/riscv-pk.spec: stage2-riscv-pk/riscv-pk.spec.in
	sed -e 's/@COMMIT@/$(RISCV_PK_COMMIT)/g' \
	    -e 's/@SHORTCOMMIT@/$(RISCV_PK_SHORTCOMMIT)/g' \
	    < $^ > $@-t
	mv $@-t $@

stamp-riscv-pk-installed:
	rm -f $@
	@rpm -q riscv-pk >/dev/null || { \
	  echo "ERROR: You must install riscv-pk:"; \
	  echo; \
	  echo "       dnf copr enable rjones/riscv"; \
	  echo "       dnf install riscv-pk"; \
	  echo; \
	  echo "OR: you can build it yourself from the stage2-riscv-pk directory."; \
	  echo; \
	  exit 1; \
	}
	touch $@

# Stage 3

stage3: stage3-kernel/linux-$(KERNEL_VERSION)/vmlinux

stage3-kernel/linux-$(KERNEL_VERSION)/vmlinux:
	rm -rf stage3-kernel/linux-$(KERNEL_VERSION)
	cp -a $(LOCAL_LINUX_GIT_COPY) stage3-kernel/linux-$(KERNEL_VERSION) || { \
	  mkdir stage3-kernel/linux-$(KERNEL_VERSION) && \
	  cd stage3-kernel/linux-$(KERNEL_VERSION) && \
	  git init; \
	}
	cd stage3-kernel/linux-$(KERNEL_VERSION) && \
	git remote add riscv https://github.com/riscv/riscv-linux && \
	git fetch riscv && \
	git checkout -f linux-4.1.y-riscv && \
	make mrproper && \
	make ARCH=riscv defconfig && \
	make ARCH=riscv CONFIG_CROSS_COMPILE=riscv64-unknown-elf- vmlinux
	ls -l $@

# Stage 4

stage4:
	echo "XXX TO DO"
	exit 1

.NOTPARALLEL:
