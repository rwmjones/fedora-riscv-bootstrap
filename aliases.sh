# Any useful aliases can go here.
alias all_rpms="rpm --nodeps -Uvh /rpmbuild/RPMS/riscv64/*.rpm /rpmbuild/RPMS/noarch/*.rpm"

alias install_tdnf="rpm --nodeps -Uvh /rpmbuild/RPMS/riscv64/{tdnf,librepo,hawkey,expat,libsolv,libcurl,gpgme,libassuan,openssl-libs,nss,nss-util,nspr,glib2,libgpg-error,pcre,libdb,rpm,rpm-libs,popt,libcap,libacl,lua,bzip2-libs,libattr,nss-softokn,nss-softokn-freebl,sqlite-libs}-[0-9]*.rpm; ldconfig; rpm --initdb"
