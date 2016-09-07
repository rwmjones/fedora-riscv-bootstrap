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

hostname stage4-builder
echo stage4-builder.fedoraproject.org > /etc/hostname

# Set up the PATH.  The GCC path is a hack because I wasn't able to
# find the right flags for configuring GCC.
PATH=/usr/libexec/gcc/riscv64-unknown-linux-gnu/6.1.0:\
/usr/local/bin:\
/usr/local/sbin:\
/usr/bin:\
/usr/sbin:\
/bin:\
/sbin
export PATH

echo
echo "This is the stage4 disk image automatic builder"
echo

PS1='stage4-builder:\w\$ '
export PS1

# Cleanup function called on failure or exit.
cleanup ()
{
    set +e
    # Sync disks and shut down.
    sync
    sleep 5
    sync
    mount.static -o remount,ro / >&/dev/null
    poweroff
}
trap cleanup INT QUIT TERM EXIT ERR

# Start the automatic build process.
set -x
set -e

rm -f /var/tmp/stage4-disk.img
rm -f /var/tmp/stage4-disk.img-t
rm -rf /var/tmp/mnt

# Unpack the empty template disk image and loop-back mount it.
tar -C /var/tmp -zxSf /var/tmp/stage4-disk.img-template.tar.gz
mv /var/tmp/stage4-disk.img-template /var/tmp/stage4-disk.img-t

mkdir /var/tmp/mnt
mount.static -o loop /var/tmp/stage4-disk.img-t /var/tmp/mnt

# Build the RPMs into the stage4 chroot.
rpm -ivh --root /var/tmp/mnt \
    /rpmbuild/RPMS/noarch/*.rpm /rpmbuild/RPMS/riscv64/*.rpm \
    |& tee /var/tmp/output || {
    < /var/tmp/output grep "is needed by" | awk '{print $1}' | sort -u
    exit 1
}

sync
umount /var/tmp/mnt

# Disk image is built, so move it to the final filename.
# guestfish downloads this, but if it doesn't exist, guestfish
# fails indicating the earlier error.
mv /var/tmp/stage4-disk.img-t /var/tmp/stage4-disk.img

# cleanup() is called automatically here.
