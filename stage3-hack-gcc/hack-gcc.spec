%global debug_package %{nil}

Name:           hack-gcc
Version:        6.1.0
# Make sure the release is 0.x so the real GCC will override this package.
Release:        0.0
Summary:        RISC-V GCC (binary hack)
License:        GPLv2+

Source0:        riscv-gcc-%{version}-binary.tar.gz

# For /etc/profile.d
Requires:       setup

# Make it look like the real GCC package.
Provides:       gcc = %{version}
Provides:       gcc-c++ = %{version}

# Not found by elfdeps for some reason:
Provides:       libgcc_s.so.1()(64bit)
Provides:       libgcc_s.so.1(GCC_3.0)(64bit)
Provides:       libgcc_s.so.1(GCC_3.3)(64bit)
Provides:       libgcc_s.so.1(GCC_3.3.1)(64bit)
Provides:       libgcc_s.so.1(GCC_3.3.4)(64bit)
Provides:       libgcc_s.so.1(GCC_3.4)(64bit)
Provides:       libgcc_s.so.1(GCC_3.4.2)(64bit)
Provides:       libgcc_s.so.1(GCC_3.4.4)(64bit)
Provides:       libgcc_s.so.1(GCC_4.0.0)(64bit)
Provides:       libgcc_s.so.1(GCC_4.2.0)(64bit)
Provides:       libgcc_s.so.1(GCC_4.3.0)(64bit)
Provides:       libgcc_s.so.1(GCC_4.7.0)(64bit)
Provides:       libgcc(riscv-64)


%description
Binary hack of GCC.  This will shortly be replaced by a
proper GCC.


%install
zcat %{SOURCE0} | tar -xf - -C $RPM_BUILD_ROOT

# Some bogus leftover files.
rm $RPM_BUILD_ROOT/usr/lib/libsupc++.a
rm $RPM_BUILD_ROOT/usr/lib/libsupc++.la

# Remove info directory file.
rm $RPM_BUILD_ROOT/usr/share/info/dir

# We need to fix the path.
mkdir -p $RPM_BUILD_ROOT/etc/profile.d
cat > $RPM_BUILD_ROOT/etc/profile.d/gcc.sh <<'EOF'
PATH=/usr/libexec/gcc/riscv64-unknown-linux-gnu/%{version}:$PATH
EOF


%files
%{_sysconfdir}/profile.d/gcc.sh
%{_bindir}/*
%{_includedir}/*
%{_libdir}/gcc/riscv64-unknown-linux-gnu
%{_libdir}/*
%{_libexecdir}/gcc/riscv64-unknown-linux-gnu/%{version}
%{_infodir}/*.info*
%{_datadir}/locale/*/LC_MESSAGES/*.mo
%{_mandir}/man1/*.1*
%{_mandir}/man7/*.7*
%{_datadir}/gcc-%{version}/*



%changelog
