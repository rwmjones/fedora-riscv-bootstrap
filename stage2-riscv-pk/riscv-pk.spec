%global debug_package %{nil}

%global commit      927979c5af6a69360b5dd61d3b17cd06ae73d1ac
%global shortcommit 927979c5

Name:           riscv-pk
Version:        0
Release:        0.1.git%{shortcommit}%{?dist}
Summary:        RISC-V proxy kernel (pk) and boot loader (bbl)
License:        BSD

URL:            https://github.com/lowRISC/riscv-pk
Source0:        https://github.com/riscv/%{name}/archive/%{commit}/%{name}-%{shortcommit}.tar.gz

BuildRequires:  riscv-gnu-toolchain


%description
This is the RISC-V fork of the GNU cross-compiler toolchain.  It
includes binutils and GCC.


%prep
%setup -q -n %{name}-%{commit}


%build
mkdir build
pushd build
# Setting RUN to /bin/true prevents pk from looking for the 'spike'
# RISC-V cycle-accurate emulator, which would be needed to run tests
# but we don't care about here.
../configure --prefix=%{_prefix} \
             --libdir=%{_libdir} \
             --host=riscv64-unknown-elf RUN=/bin/true

make
popd


%install
pushd build
make install DESTDIR=$RPM_BUILD_ROOT
popd


%files
%doc README.md LICENSE
%{_bindir}/bbl
%{_bindir}/dummy_payload
%{_bindir}/pk
%{_includedir}/riscv-pk
%{_prefix}/lib/riscv-pk


%changelog
