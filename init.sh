#!/bin/bash -
# Init script installed in stage3 disk image.

# Root filesystem is mounted as ro, remount it as rw.
mount.static -o remount,rw /

# Mount standard filesystems.
mount.static -t proc /proc /proc
mount.static -t sysfs /sys /sys
mount.static -t tmpfs -o "nosuid,size=20%,mode=0755" tmpfs /run
mkdir -p /run/lock

# XXX devtmpfs

# Initialize dynamic linker cache.
ldconfig /usr/lib64 /usr/lib /lib64 /lib

# There is no hardware clock, just ensure the date is not miles out.
date `date -r /usr/bin +%m%d%H%M%Y`

hostname stage3
echo stage3.fedoraproject.org > /etc/hostname

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
