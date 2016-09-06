# Any useful aliases can go here.
alias all_rpms="rpm --nodeps -Uvh /rpmbuild/RPMS/riscv64/*.rpm /rpmbuild/RPMS/noarch/*.rpm"
alias prep_glibc="rpm --nodeps -Uvh /rpmbuild/RPMS/riscv64/{bash,info,make}-*.rpm"
alias prep_systemd="rpm --nodeps -Uvh /rpmbuild/RPMS/riscv64/{bash,expat,libtool,make,perl}-* /rpmbuild/RPMS/noarch/{autoconf,automake,intltool,perl}-*"

# Missing deps:
#  missing_deps <some list of RPMs>
# shows the missing dependencies from the set of RPMs.
missing_deps ()
{
    rpm -Uvh --test "$@" |& grep "is needed by" | awk '{print $1}' | sort -u
}
