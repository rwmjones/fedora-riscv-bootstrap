#!/bin/bash -
# Init script installed in stage3 disk image.

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
# Work around default search path problems.
export LD_LIBRARY_PATH=/usr/lib64:/usr/lib

# Root filesystem is mounted as ro, remount it as rw.
mount.static -o remount,rw /

# Mount standard filesystems.
mount.static -t proc /proc /proc
mount.static -t sysfs /sys /sys
mount.static -t tmpfs -o "nosuid,size=20%,mode=0755" tmpfs /run
mkdir -p /run/lock
mkdir -p /dev/pts
mount.static -t devpts /dev/pts /dev/pts
mkdir -p /dev/shm
mount.static -t tmpfs -o mode=1777 shmfs /dev/shm

# XXX devtmpfs
#mount.static -t devtmpfs /dev /dev

rm -f /dev/loop*
mknod /dev/loop-control c 10 237
mknod /dev/loop0 b 7 0
mknod /dev/loop1 b 7 1
mknod /dev/loop2 b 7 2
rm -f /dev/null
mknod /dev/null c 1 3
rm -f /dev/ptmx
mknod /dev/ptmx c 5 2
rm -f /dev/tty /dev/zero
mknod /dev/tty c 5 0
mknod /dev/zero c 1 5
rm -f /dev/random /dev/urandom
mknod /dev/random c 1 8
mknod /dev/urandom c 1 9

# Initialize dynamic linker cache.
ldconfig /usr/lib64 /usr/lib /lib64 /lib

# Fix owner of umount binary.
chown root.root /usr/bin/umount

# There is no hardware clock, just ensure the date is not miles out.
date `date -r /var/tmp +%m%d%H%M%Y`

hostname stage4-builder
echo stage4-builder.fedoraproject.org > /etc/hostname

echo
echo "This is the stage4 disk image automatic builder"
echo

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

if test ! -f /rpmsdone; then
    set -x

    # On the first run, we need to install the new RPM and any
    # immediate dependencies.
    pkgs=tdnf,librepo,hawkey,expat,libsolv,libcurl,gpgme,libassuan,openssl-libs,nss,nss-util,nspr,glib2,libgpg-error,pcre,libdb,rpm,rpm-libs,popt,libcap,libacl,lua,bzip2-libs,libattr,nss-softokn,nss-softokn-freebl,sqlite-libs,lsof,libselinux,libsepol
    rpm --nodeps -Uvh /rpmbuild/RPMS/riscv64/{$pkgs}-[0-9]*.rpm
    ldconfig
    rm -f /var/lib/rpm/__db*
    rpm --initdb

    touch /rpmsdone
else
    # On the second run, we do the actual build.
    set -e
    #set -x

    rm -f /var/tmp/stage4-disk.img
    rm -f /var/tmp/stage4-disk.img-t
    rm -rf /var/tmp/mnt

    # Don't install debuginfo packages in the stage4 image.
    rm /rpmbuild/RPMS/*/*-debuginfo-*.rpm

    # Unpack the empty template disk image and loop-back mount it.
    tar -C /var/tmp -zxSf /var/tmp/stage4-disk.img-template.tar.gz
    mv /var/tmp/stage4-disk.img-template /var/tmp/stage4-disk.img-t

    mkdir /var/tmp/mnt
    mount.static -o loop /var/tmp/stage4-disk.img-t /var/tmp/mnt

    # Bind-mount some filesystems into the chroot so the RPM scripts
    # can run cleanly.
    mkdir -p /var/tmp/mnt/dev
    mount.static --rbind /dev /var/tmp/mnt/dev
    mkdir -p /var/tmp/mnt/proc
    mount.static --rbind /proc /var/tmp/mnt/proc
    mkdir -p /var/tmp/mnt/sys
    mount.static --rbind /sys /var/tmp/mnt/sys

    # Iteratively install RPMs, removing any with failed dependencies.
    while true; do
        echo Running rpm on current package set ...
        rpm -Uvh --root /var/tmp/mnt/ \
            /rpmbuild/RPMS/noarch/*.rpm /rpmbuild/RPMS/riscv64/*.rpm \
            >& /var/tmp/output ||:
        # If RPM didn't print "error", then it succeeded:
        if ! grep -sq "error: " /var/tmp/output; then break; fi

        pkgs_to_delete=$(
            grep 'is needed by' </var/tmp/output |
                awk '{print $NF}' |
                sort -u)
        # No packages left to delete, RPM probably failed for some other reason:
        if [ "x$pkgs_to_delete" = "x" ]; then break; fi

        for pkg in $pkgs_to_delete; do
            echo Removing $pkg because:
            grep "is needed by $pkg" /var/tmp/output ||:
            # We have to remove the epoch, since it's not part of the filename.
            rpm=$(echo $pkg.rpm | sed 's/-[0-9]\+:/-/g')
            find /rpmbuild -name $rpm -delete
        done
    done

    # Display the output from the final, hopefully successful, RPM command.
    cat /var/tmp/output

    sync
    kill -HUP `lsof -t /var/tmp/mnt` ||:
    sleep 5
    sync
    kill -9 `lsof -t /var/tmp/mnt` ||:
    sleep 1
    sync
    umount /var/tmp/mnt

    # Disk image is built, so move it to the final filename.
    # guestfish downloads this, but if it doesn't exist, guestfish
    # fails indicating the earlier error.
    mv /var/tmp/stage4-disk.img-t /var/tmp/stage4-disk.img
fi

# cleanup() is called automatically here.
