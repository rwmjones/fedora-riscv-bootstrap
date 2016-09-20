#!/bin/bash -
# Temporary init script installed in stage4 disk image.
# Once we have systemd packaged, this will be removed.

# Set up the PATH.
PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin
export PATH

# Root filesystem is mounted as ro, remount it as rw.
mount -o remount,rw /

# Mount standard filesystems.
mount -t proc /proc /proc
mount -t sysfs /sys /sys
mount -t tmpfs -o "nosuid,size=20%,mode=0755" tmpfs /run
mkdir -p /run/lock

# XXX devtmpfs

# Initialize dynamic linker cache.
ldconfig /usr/lib64 /usr/lib /lib64 /lib

# There is no hardware clock, just ensure the date is not miles out.
date `date -r /init +%m%d%H%M%Y`

hostname stage4
echo stage4.fedoraproject.org > /etc/hostname

echo
echo "Welcome to the Fedora/RISC-V stage4 disk image"
echo "https://fedoraproject.org/wiki/Architectures/RISC-V"
echo

PS1='stage4:\w\$ '
export PS1

# Run bash.
bash -il

# Sync disks and shut down.
sync
mount -o remount,ro / >&/dev/null
poweroff
