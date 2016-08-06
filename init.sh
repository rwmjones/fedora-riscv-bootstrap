#!/bin/bash -
# Init script installed in stage3 disk image.

# Root filesystem is mounted as ro, remount it as rw.
mount -o remount,rw /

# Mount standard filesystems.
mount -t proc /proc /proc
mount -t sysfs /sys /sys
mount -t tmpfs -o "nosuid,size=20%,mode=0755" tmpfs /run
mkdir -p /run/lock

# XXX devtmpfs

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
