#!/bin/bash -
# Init script installed in stage3 disk image.

echo
echo "Welcome to the Fedora/RISC-V stage3 disk image"
echo "https://fedoraproject.org/wiki/Architectures/RISC-V"
echo

PS1='stage3:\w\$ '
export PS1

# Run bash.
bash -i

# Sync disks and shut down.
sync
poweroff
