# Refer to the README file to understand how Fedora on RISC-V is
# bootstrapped.

all: stage1 stage2 stage3 stage4

stage1: stage1-riscv-qemu/riscv-qemu-94f5eb73.tar.gz \
	stamp-riscv-qemu-installed

stage1-riscv-qemu/riscv-qemu-94f5eb73.tar.gz:
	rm -f $@ $@-t
	wget 'https://github.com/riscv/riscv-qemu/archive/94f5eb73091fb4fe272db3e943f173ecc0f78ffd/riscv-qemu-94f5eb73.tar.gz' -O $@-t
	mv $@-t $@

stamp-riscv-qemu-installed:
	rm -f $@
	@rpm -q riscv-qemu >/dev/null || { \
	  echo "ERROR: You must install riscv-qemu:"; \
	  echo; \
	  echo "       dnf copr enable rjones/riscv-qemu"; \
	  echo "       dnf install riscv-qemu"; \
	  echo; \
	  echo "OR: you can build it yourself from the stage1-riscv-qemu directory."; \
	  echo; \
	  exit 1; \
	}
	touch $@

stage2:
	echo "XXX TO DO"
	exit 1

stage3:
	echo "XXX TO DO"
	exit 1

stage4:
	echo "XXX TO DO"
	exit 1

.NOTPARALLEL:
