# Any useful aliases can go here.
alias all_rpms="rpm --nodeps -Uvh /rpmbuild/RPMS/riscv64/*.rpm /rpmbuild/RPMS/noarch/*.rpm"
alias prep_systemd="rpm --nodeps -Uvh /rpmbuild/RPMS/riscv64/{bash,expat,libtool,make,perl}-* /rpmbuild/RPMS/noarch/{autoconf,automake,intltool,perl}-*"
