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

# Don't install any -devel packages.
rm -f /rpmbuild/RPMS/*/*-devel-*.rpm

# Blacklist RPMs which have missing dependencies.
rm -f /rpmbuild/RPMS/*/{\
acl,\
bc,\
compat-libmpc,\
curl,\
cyrus-sasl,\
dbus*,\
doxygen-latex,\
elfutils,\
expect,\
emacs-gettext,\
emacs-terminal,\
fontawesome-fonts*,\
gettext,\
gettext-libs,\
git*,\
glib2-tests,\
gmp-c++,\
gnupg2,\
gnupg2-smime,\
gperf,\
groff,\
groff-base,\
groff-doc,\
groff-perl,\
groff-x11,\
krb5-server,\
lato-fonts,\
libacl,\
libcurl,\
libdb-cxx,\
libedit,\
libmpc,\
libtool,\
libutempter,\
nano,\
nscd,\
nss-sysvinit,\
nss-tools,\
openldap*,\
openssl-perl,\
p11-kit-trust,\
pcre-cpp,\
pcre-tools,\
perl-Archive-Zip,\
perl-CPAN,\
perl-ExtUtils*,\
perl-File-Fetch,\
perl-File-HomeDir,\
perl-Filter,\
perl-Filter-Simple,\
perl-Git-SVN,\
perl-IO-Compress,\
perl-IPC-Cmd,\
perl-Module-Load-Conditional,\
perl-Net-Ping,\
perl-Pod-Perldoc,\
perl-URI,\
perl-core,\
python-debug,\
python-docutils,\
python-pygments,\
python-sphinx-doc,\
python-sphinx-latex,\
python2-sphinx,\
python3-docutils,\
python3-sphinx,\
rpm-cron,\
rsync,\
rsync,\
screen,\
sqlite,\
sqlite-analyzer,\
sqlite-tcl,\
system-python-libs,\
texinfo-tex,\
util-linux,\
uuidd\
}-[0-9]*.rpm

# Build the RPMs into the stage4 chroot.
rpm -ivh --root /var/tmp/mnt \
    /rpmbuild/RPMS/noarch/*.rpm /rpmbuild/RPMS/riscv64/*.rpm \
    |& tee /var/tmp/output
if grep -sq "error: " /var/tmp/output; then
    grep "is needed by" < /var/tmp/output | awk '{print $5}' | sort -u
    exit 1
fi

sync
umount /var/tmp/mnt

# Disk image is built, so move it to the final filename.
# guestfish downloads this, but if it doesn't exist, guestfish
# fails indicating the earlier error.
mv /var/tmp/stage4-disk.img-t /var/tmp/stage4-disk.img

# cleanup() is called automatically here.
