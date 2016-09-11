# Any useful aliases can go here.
alias all_rpms="rpm --nodeps -Uvh /rpmbuild/RPMS/riscv64/*.rpm /rpmbuild/RPMS/noarch/*.rpm"

alias install_tdnf="rpm --nodeps -Uvh /rpmbuild/RPMS/riscv64/{tdnf,librepo,hawkey,expat,libsolv,libcurl,gpgme,libassuan,openssl-libs,nss,nss-util,nspr,glib2,libgpg-error,pcre,libdb}-[0-9]*.rpm; ldconfig"

# Missing deps:
#  missing_deps <some list of RPMs>
# shows the missing dependencies from the set of RPMs.
missing_deps ()
{
    rpm -Uvh --test "$@" |& grep "is needed by" | awk '{print $1}' | sort -u
}
