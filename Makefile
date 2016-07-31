# Refer to the README file to understand how Fedora on RISC-V is
# bootstrapped.

all: stage1 stage2 stage3 stage4

# Stage 1

stage1: stage1-riscv-qemu/riscv-qemu-94f5eb73.tar.gz \
	stamp-riscv-qemu-installed

stage1-riscv-qemu/riscv-qemu-94f5eb73.tar.gz:
	rm -f $@ $@-t
	wget -O $@-t 'https://github.com/riscv/riscv-qemu/archive/94f5eb73091fb4fe272db3e943f173ecc0f78ffd/riscv-qemu-94f5eb73.tar.gz'
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

# Stage 2

stage2: stage2-riscv-gnu-toolchain/riscv-gnu-toolchain-1374381e.tar.gz \
	stage2-riscv-gnu-toolchain/binutils-2.26.tar.gz \
	stage2-riscv-gnu-toolchain/gcc-6.1.0.tar.gz \
	stage2-riscv-gnu-toolchain/glibc-2.23.tar.gz \
	stage2-riscv-gnu-toolchain/newlib-2.2.0.tar.gz \
	stamp-riscv-gnu-toolchain-installed

stage2-riscv-gnu-toolchain/riscv-gnu-toolchain-1374381e.tar.gz:
	rm -f $@ $@-t
	wget -O $@-t https://github.com/lowRISC/riscv-gnu-toolchain/archive/1374381e01b30832581d65a56219388fe7d47584/riscv-gnu-toolchain-1374381e.tar.gz
	mv $@-t $@

stage2-riscv-gnu-toolchain/binutils-2.26.tar.gz:
	rm -f $@ $@-t
	wget -O $@-t http://mirrors.kernel.org/gnu/binutils/binutils-2.26.tar.gz
	mv $@-t $@

stage2-riscv-gnu-toolchain/gcc-6.1.0.tar.gz:
	rm -f $@ $@-t
	wget -O $@-t http://mirrors.kernel.org/gnu/gcc/gcc-6.1.0/gcc-6.1.0.tar.gz
	mv $@-t $@

stage2-riscv-gnu-toolchain/glibc-2.23.tar.gz:
	rm -f $@ $@-t
	wget -O $@-t http://mirrors.kernel.org/gnu/glibc/glibc-2.23.tar.gz
	mv $@-t $@

stage2-riscv-gnu-toolchain/newlib-2.2.0.tar.gz:
	rm -f $@ $@-t
	wget -O $@-t ftp://sourceware.org/pub/newlib/newlib-2.2.0.tar.gz
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

# Stage 3

stage3:
	echo "XXX TO DO"
	exit 1

# Stage 4

stage4:
	echo "XXX TO DO"
	exit 1

.NOTPARALLEL:
