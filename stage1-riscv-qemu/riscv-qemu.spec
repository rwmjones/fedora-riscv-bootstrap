%global debug_package %{nil}

%global commit      94f5eb73091fb4fe272db3e943f173ecc0f78ffd
%global shortcommit 94f5eb73

Name:           riscv-qemu
Version:        2.5.0
Release:        0.git%{shortcommit}.1%{?dist}
Summary:        RISC-V fork of QEMU
License:        GPLv2+ and LGPLv2+ and BSD

URL:            https://github.com/riscv/riscv-qemu
Source0:        https://github.com/riscv/%{name}/archive/%{commit}/%{name}-%{shortcommit}.tar.gz

# These were just copied from qemu.spec, they are probably not
# all required.
BuildRequires: texi2html
BuildRequires: texinfo
BuildRequires: perl-podlators
BuildRequires: qemu-sanity-check-nodeps
BuildRequires: kernel
BuildRequires: iasl
BuildRequires: chrpath
BuildRequires: SDL2-devel
BuildRequires: zlib-devel
BuildRequires: gnutls-devel
BuildRequires: cyrus-sasl-devel
BuildRequires: libaio-devel
BuildRequires: pulseaudio-libs-devel
BuildRequires: alsa-lib-devel
BuildRequires: libiscsi-devel
BuildRequires: libnfs-devel
BuildRequires: snappy-devel
BuildRequires: lzo-devel
BuildRequires: ncurses-devel
BuildRequires: libattr-devel
BuildRequires: libcap-devel
BuildRequires: libcap-ng-devel
BuildRequires: usbredir-devel >= 0.5.2
BuildRequires: gperftools-devel
BuildRequires: spice-protocol >= 0.12.2
BuildRequires: spice-server-devel >= 0.12.0
BuildRequires: libseccomp-devel >= 2.3.0
BuildRequires: libcurl-devel
BuildRequires: ceph-devel >= 0.61
BuildRequires: systemtap
BuildRequires: systemtap-sdt-devel
BuildRequires: libjpeg-devel
BuildRequires: libpng-devel
BuildRequires: libuuid-devel
BuildRequires: bluez-libs-devel
BuildRequires: brlapi-devel
BuildRequires: libfdt-devel
BuildRequires: pixman-devel
BuildRequires: glusterfs-devel >= 3.4.0
BuildRequires: glusterfs-api-devel >= 3.4.0
BuildRequires: libusbx-devel
BuildRequires: libssh2-devel
BuildRequires: gtk3-devel
BuildRequires: vte3-devel
BuildRequires: gettext
BuildRequires: librdmacm-devel
BuildRequires: xen-devel
BuildRequires: numactl-devel
BuildRequires: bzip2-devel
BuildRequires: libepoxy-devel
BuildRequires: libtasn1-devel
BuildRequires: libcacard-devel >= 2.5.0
BuildRequires: virglrenderer-devel
BuildRequires: mesa-libgbm-devel
BuildRequires: glibc-static pcre-static glib2-static zlib-static

# We don't bother packaging ancillary files; use the ones provided by
# the real QEMU.
Requires: qemu-system-x86

%description
This is the RISC-V fork of QEMU.


%prep
%setup -q -n %{name}-%{commit}


%build
./configure --prefix=%{_prefix} --target-list=riscv-softmmu --disable-werror
make


%install
make install DESTDIR=$RPM_BUILD_ROOT

# Remove ancillary files.
rm $RPM_BUILD_ROOT%{_bindir}/ivshmem*
rm $RPM_BUILD_ROOT%{_bindir}/qemu-{ga,img,io,nbd}
rm $RPM_BUILD_ROOT%{_bindir}/virtfs-proxy-helper
rm -r $RPM_BUILD_ROOT%{_libexecdir}
rm -r $RPM_BUILD_ROOT%{_datadir}


%files
%doc README COPYING
%{_bindir}/qemu-system-riscv


%changelog
