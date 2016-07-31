%global debug_package %{nil}

# Don't rm -rf $RPM_BUILD_ROOT at the top of install rule.
%global __spec_install_pre %{___build_pre}

%global commit      1374381e01b30832581d65a56219388fe7d47584
%global shortcommit 1374381e

Name:           riscv-gnu-toolchain
Version:        0
Release:        0.1.git%{shortcommit}%{?dist}
Summary:        RISC-V GNU cross-toolchain, containing binutils and GCC
License:        GPLv2+ and LGPLv2+ and BSD

URL:            https://github.com/riscv/riscv-qemu
Source0:        https://github.com/riscv/%{name}/archive/%{commit}/%{name}-%{shortcommit}.tar.gz

Source1:        http://mirrors.kernel.org/gnu/binutils/binutils-2.26.tar.gz
Source2:        http://mirrors.kernel.org/gnu/glibc/glibc-2.23.tar.gz
Source3:        http://mirrors.kernel.org/gnu/gcc/gcc-6.1.0/gcc-6.1.0.tar.gz
Source4:        ftp://sourceware.org/pub/newlib/newlib-2.2.0.tar.gz

# XXX These BuildRequires are just culled from the GCC spec
# and probably overestimate the real requirements.
BuildRequires: binutils
BuildRequires: glibc-static
BuildRequires: zlib-devel, gettext, bison, flex
BuildRequires: texinfo, texinfo-tex, /usr/bin/pod2man
BuildRequires: systemtap-sdt-devel
BuildRequires: gmp-devel, mpfr-devel, libmpc-devel
BuildRequires: hostname, procps
BuildRequires: gdb
BuildRequires: glibc-devel
BuildRequires: elfutils-devel
BuildRequires: elfutils-libelf-devel
BuildRequires: glibc
BuildRequires: glibc-devel
BuildRequires: libunwind
BuildRequires: isl
BuildRequires: isl-devel
BuildRequires: doxygen
BuildRequires: graphviz, texlive-collection-latex


%description
This is the RISC-V fork of the GNU cross-compiler toolchain.  It
includes binutils and GCC.


%prep
%setup -q -n %{name}-%{commit}


%build
%configure

# The ordinary Makefile downloads upstream GNU packages.  Instead we
# provide these as local files.  Note this is "DISTDIR" not "DESTDIR".
export DISTDIR=%{_sourcedir}

# Since the Makefile installs as it goes along, set DESTDIR too, and
# clean the buildroot now (instead of at the top of install).
export DESTDIR=$RPM_BUILD_ROOT
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT

# We need to use the tools we built as we go along.
export PATH=$RPM_BUILD_ROOT%{_bindir}:$PATH

make

# The 'make linux' rule builds GCC linked against glibc (instead of
# newlib).  However I couldn't make this work, and it's not really
# needed anyway.
#make linux


%install
# Not needed since the make installs as it goes along.
#make install DESTDIR=$RPM_BUILD_ROOT

# Remove some documentation, language files
rm -r $RPM_BUILD_ROOT%{_datadir}/info
rm -r $RPM_BUILD_ROOT%{_mandir}
rm -r $RPM_BUILD_ROOT%{_datadir}/locale

# Remove this libtool linker file.
rm $RPM_BUILD_ROOT%{_libdir}/libcc1.la


%files
%doc README.md LICENSE
%{_bindir}/riscv64-unknown-elf-*
#%{_bindir}/riscv64-unknown-linux-gnu-*
%{_libdir}/libcc1.so
%{_libdir}/libcc1.so.0
%{_libdir}/libcc1.so.0.0.0
%{_libexecdir}/gcc/riscv64-unknown-elf
#%{_libexecdir}/gcc/riscv-unknown-linux-gnu
%{_prefix}/lib/gcc/riscv64-unknown-elf
#%{_prefix}/lib/gcc/riscv64-unknown-linux-gnu
%{_prefix}/riscv64-unknown-elf
#%{_prefix}/riscv64-unknown-linux-gnu
%{_datadir}/gcc-6.1.0


%changelog
