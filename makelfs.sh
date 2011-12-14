#!/bin/bash

# Setting
adminuser=jqh

lfsroot=/mnt/lfs
rootfs=/dev/sdb1
homefs=/dev/sdb2
swapfs=/dev/sdb3
pkgsrc=/home/jqh/lfs/lfs/lfs-sources
scriptfile=/home/jqh/lfs/lfs/makelfs.sh

ipaddr=192.168.1.110
netmask=24
broadcast=192.168.1.255
gateway=192.168.1.1
dnsserv=202.109.15.135
hostname=lfs
domain=home.org

# Packages name
pkg_autoconf=autoconf-2.61.tar.bz2
pkg_automake=automake-1.10.tar.bz2
pkg_bash=bash-3.2.tar.gz
pkg_binutils=binutils-2.17.tar.bz2
pkg_bison=bison-2.3.tar.bz2
pkg_bzip2=bzip2-1.0.4.tar.gz
pkg_coreutils=coreutils-6.9.tar.bz2
pkg_db=db-4.5.20.tar.gz
pkg_dejagnu=dejagnu-1.4.4.tar.gz
pkg_diffutils=diffutils-2.8.1.tar.gz
pkg_e2fsprogs=e2fsprogs-1.40.2.tar.gz
pkg_expect=expect-5.43.0.tar.gz
pkg_file=file-4.21.tar.gz
pkg_findutils=findutils-4.2.31.tar.gz
pkg_flex=flex-2.5.33.tar.bz2
pkg_gawk=gawk-3.1.5.tar.bz2
pkg_gcc=gcc-4.1.2.tar.bz2
pkg_gettext=gettext-0.16.1.tar.gz
pkg_glibc=glibc-2.5.1.tar.bz2
pkg_grep=grep-2.5.1a.tar.bz2
pkg_groff=groff-1.18.1.4.tar.gz
pkg_grub=grub-0.97.tar.gz
pkg_gzip=gzip-1.3.12.tar.gz
pkg_ianaetc=iana-etc-2.20.tar.bz2
pkg_inetutils=inetutils-1.5.tar.gz
pkg_iproute2=iproute2-2.6.20-070313.tar.gz
pkg_kbd=kbd-1.12.tar.bz2
pkg_less=less-406.tar.gz
pkg_lfsbootscripts=lfs-bootscripts-6.3.tar.bz2
pkg_libtool=libtool-1.5.24.tar.gz
pkg_linux=linux-2.6.22.5.tar.bz2
pkg_m4=m4-1.4.10.tar.bz2
pkg_make=make-3.81.tar.bz2
pkg_mandb=man-db-2.4.4.tar.gz
pkg_manpages=man-pages-2.63.tar.bz2
pkg_mktemp=mktemp-1.5.tar.gz
pkg_moduleinittools=module-init-tools-3.2.2.tar.bz2
pkg_ncurses=ncurses-5.6.tar.gz
pkg_patch=patch-2.5.4.tar.gz
pkg_perl=perl-5.8.8.tar.bz2
pkg_procps=procps-3.2.7.tar.gz
pkg_psmisc=psmisc-22.5.tar.gz
pkg_readline=readline-5.2.tar.gz
pkg_sed=sed-4.1.5.tar.gz
pkg_shadow=shadow-4.0.18.1.tar.bz2
pkg_sysklogd=sysklogd-1.4.1.tar.gz
pkg_sysvinit=sysvinit-2.86.tar.gz
pkg_tar=tar-1.18.tar.bz2
pkg_tcl=tcl8.4.15-src.tar.gz
pkg_texinfo=texinfo-4.9.tar.bz2
pkg_udev=udev-113.tar.bz2
pkg_utillinux=util-linux-2.12r.tar.bz2
pkg_vim=vim-7.1.tar.bz2
pkg_zlib=zlib-1.2.3.tar.gz

# Package building routin
function extract_pkg {
	pkgname=$1
	cd $lfsbuild
	tar xvf $pkgname  	
	dirname=$(echo $pkgname | sed 's/\.tar.*$//')
	cd $lfsbuild/$dirname
}

function clean_pkg {
	cd $lfsbuild
	rm -rf $lfsbuild/$dirname
}

function print_difftime {
	end=$2
	begin=$1
	diff=$(expr $end - $begin)
	hours=$(expr $diff / 3600)
	diff=$(expr $diff % 3600)
	mins=$(expr $diff / 60)
	diff=$(expr $diff % 60)
	secs=$diff
	echo -en "$hours hrs $mins mins $secs secs used\n"
}

function ack_admin {
	sendmail $adminuser < $logfile
}


function build_pkg {
	pkg_name=$1
	do_build=$2
	begintime=$(date +%s)
	dirname=$(echo $pkg_name | sed 's/\.tar.*$//')
	extract_pkg $pkg_name

	$do_build

	err=$?
	clean_pkg 
	endtime=$(date +%s)
	echo -en "$dirname build end: " >>  $logfile
	print_difftime $begintime $endtime >> $logfile
	if [ $err -ne 0 ]; then
		echo -en "$dirname build failed, exit\n" >> $logfile
		exit
	fi
#	ack_admin
}
	
function build_temporary_system {
	# Setting
	logfile=$lfsroot/lfsbuild.log
	
	# Print require host packages
	echo -en "[Message] To succesfull building LFS, packages below are required\n\n"
	
	echo -en "Bash-2.05a\\n\tyou have: "
	bash --version | head -n1 | cut -d" " -f2-4
	
	echo -en "Binutils-2.12 (<=2.17)\n\tyou have: "
	echo -en "Binutils: "; ld --version | head -n1 | cut -d" " -f3-4
	
	echo -en "Bison-1.875\n\tyou have: "
	bison --version | head -n1
	
	echo -en "Bzip2-1.0.2\n\tyou have: "
	bzip2 --version 2>&1 < /dev/null | head -n1 | cut -d" " -f1,6-
	
	echo -en "Coreutils-5.0 \n\tyou have: "
	echo -en "Coreutils: "; chown --version | head -n1 | cut -d")" -f2
	
	echo -en "Diffutils-2.8\n\tyou have: "
	diff --version | head -n1
	
	echo -en "Findutils-4.1.20\n\tyou have: "
	find --version | head -n1
	
	echo -en "Gawk-3.0\n\tyou have: "
	gawk --version | head -n1
	
	echo -en "Gcc-3.0.1 (<=4.1.2)\n\tyou have: "
	gcc --version | head -n1
	
	echo -en "Glibc-2.2.5 (<=2.5.1)\n\tyou have: "
	/lib/libc.so.6 | head -n1 | cut -d" " -f1-7
	
	echo -en "Grep-2.5\n\tyou have: "
	grep --version | head -n1
	
	echo -en "Gzip-1.2.4\n\tyou have: "
	gzip --version | head -n1
	
	echo -en "Linux Kernel-2.6.x\n\tyou have: "
	cat /proc/version
	
	echo -en "Make-3.79.1\n\tyou have: "
	make --version | head -n1
	
	echo -en "Patch-2.5.4\n\tyou have: "
	patch --version | head -n1
	
	echo -en "Sed-3.0.2\n\tyou have: "
	sed --version | head -n1
	
	echo -en "Tar-1.14\n\tyou have: "
	tar --version | head -n1
	
	echo -en "\n"
	echo -en "[Message] Please check your packages version above, press \"c\" to continue, or \"q\" to abort\n"
	echo -en "[Message] (\"c\" or \"q\"): "
	read choice
	if [ $choice = 'c' ]; then
		echo -en "[Message] Continue...\n"
	else
		exit;
	fi	
	echo -en "\n\n"
	
	
	# Create the filesystem
	for datafs in $rootfs $homefs; do
		mke2fs -jv $datafs
		echo -en "\n"
	done
	mkswap $swapfs
	echo -en "\n\n"
	
	
	# Mount the filesystems
	if [ -d $lfsroot ]; then
		echo -en "$lfsroot exists, exit\n"
		exit
	fi
	mkdir -pv $lfsroot
	mount -v -t ext3 $rootfs $lfsroot
	mkdir -pv $lfsroot/home
	mount -v -t ext3 $homefs $lfsroot/home
	/sbin/swapon -v $swapfs
	
	
	# Prepare package sources
	lfsbuild=$lfsroot/sources
	mkdir -v $lfsbuild
	chmod -v a+wt $lfsbuild
	cp -rv $pkgsrc/* $lfsbuild/
	##################################
	# Change filename for compatible #
	##################################
	pkg_tcl=tcl8.4.15.tar.gz
	mv $lfsbuild/tcl8.4.15-src.tar.gz $lfsbuild/tcl8.4.15.tar.gz
	##################################
	# End				 #
	##################################
	
	# Prepare tools rc.tar.gz
	mkdir -v $lfsroot/tools
	ln -sv $lfsroot/tools /
	
	
	# Setup environment
	set +h
	umask 022
	LC_ALL=POSIX
	PATH=/tools/bin:/bin:/usr/bin
	export lfsroot LC_ALL PATH
	

	#
	# Tools chain building
	#
	
	# Binutils
	function build_binutils {
		mkdir -v ../binutils-build &&
		cd ../binutils-build &&
		CC="gcc -B/usr/bin/" ../binutils-2.17/configure \
			--prefix=/tools --disable-nls --disable-werror &&
		make &&
		make install &&
		make -C ld clean &&
		make -C ld LIB_PATH=/tools/lib &&
		cp -v ld/ld-new /tools/bin &&
	
		cd ../ &&
		rm -rf binutils-build;
	}
	build_pkg $pkg_binutils build_binutils
	
	# GCC
	function build_gcc {
		mkdir -v ../gcc-build &&
		cd ../gcc-build &&
		CC="gcc -B/usr/bin/" ../gcc-4.1.2/configure --prefix=/tools \
			--with-local-prefix=/tools --disable-nls --enable-shared \
			--enable-languages=c &&
		make bootstrap &&
		make install &&
		ln -vs gcc /tools/bin/cc &&
	
		cd ../ &&
		rm -rf gcc-build;
	} 
	build_pkg $pkg_gcc build_gcc
	
	# Linux API Headers
	function build_linux {
		make mrproper &&
		make headers_check &&
		make INSTALL_HDR_PATH=dest headers_install &&
		cp -rv dest/include/* /tools/include;
	}
	build_pkg $pkg_linux build_linux
	
	# Glibc
	function build_glibc {
		mkdir -v ../glibc-build &&
		cd ../glibc-build &&
		../glibc-2.5.1/configure --prefix=/tools \
			--disable-profile --enable-add-ons \
			--enable-kernel=2.6.0 --with-binutils=/tools/bin \
			--without-gd --with-headers=/tools/include \
			--without-selinux &&
		make &&
		mkdir -v /tools/etc &&
		touch /tools/etc/ld.so.conf &&
		make install &&
		
		cd ../ &&
		rm -rf glibc-build;
	}
	build_pkg $pkg_glibc build_glibc
	
	# Adjusting the toolchain
	mv -v /tools/bin/{ld,ld-old}
	mv -v /tools/$(gcc -dumpmachine)/bin/{ld,ld-old}
	mv -v /tools/bin/{ld-new,ld}
	ln -sv /tools/bin/ld /tools/$(gcc -dumpmachine)/bin/ld
	
	gcc -dumpspecs | sed 's@^/lib/ld-linux.so.2@/tools&@g' \
	  > `dirname $(gcc -print-libgcc-file-name)`/specs
	
	GCC_INCLUDEDIR=`dirname $(gcc -print-libgcc-file-name)`/include &&
	find ${GCC_INCLUDEDIR}/* -maxdepth 0 -xtype d -exec rm -rvf '{}' \; &&
	rm -vf `grep -l "DO NOT EDIT THIS FILE" ${GCC_INCLUDEDIR}/*` &&
	unset GCC_INCLUDEDIR
	
	# Tcl
	function build_tcl {
		cd unix &&
		./configure --prefix=/tools &&
		make &&
		make install &&
		make install-private-headers &&
		ln -sv tclsh8.4 /tools/bin/tclsh;
	}
	build_pkg $pkg_tcl build_tcl
	
	# Expect
	function build_expect {
		cd $lfsbuild/expect-5.43 &&
	
		patch -Np1 -i ../expect-5.43.0-spawn-1.patch &&
		cp configure{,.bak} &&
		sed 's:/usr/local/bin:/bin:' configure.bak > configure &&
		./configure --prefix=/tools --with-tcl=/tools/lib \
		  --with-tclinclude=/tools/include --with-x=no &&
		make &&
		make SCRIPTS="" install &&
	
		cd ../ &&
		rm -rf $lfsbuild/expect-5.43;
	}
	build_pkg $pkg_expect build_expect
	
	# DejaGNU
	function build_dejagnu {
		./configure --prefix=/tools &&
		make install;
	}
	build_pkg $pkg_dejagnu build_dejagnu
	
	# GCC again
	function build_gcc {
		cp -v gcc/Makefile.in{,.orig} &&
		sed 's@\./fixinc\.sh@-c true@' gcc/Makefile.in.orig > gcc/Makefile.in &&
		cp -v gcc/Makefile.in{,.tmp} &&
		sed 's/^XCFLAGS =$/& -fomit-frame-pointer/' gcc/Makefile.in.tmp \
		  > gcc/Makefile.in &&
		patch -Np1 -i ../gcc-4.1.2-specs-1.patch &&
		mkdir -v ../gcc-build &&
		cd ../gcc-build &&
		../gcc-4.1.2/configure --prefix=/tools \
		    --with-local-prefix=/tools --enable-clocale=gnu \
		    --enable-shared --enable-threads=posix \
		    --enable-__cxa_atexit --enable-languages=c,c++ \
		    --disable-libstdcxx-pch &&
		make &&
		make install &&
	
		cd ../ &&
		rm -rf gcc-build;
	}
	build_pkg $pkg_gcc build_gcc
	
	# Binutils again
	function build_binutils {
		mkdir -v ../binutils-build &&
		cd ../binutils-build &&
		../binutils-2.17/configure --prefix=/tools \
			--disable-nls --with-lib-path=/tools/lib &&
		make &&
		make install &&
		make -C ld clean &&
		make -C ld LIB_PATH=/usr/lib:/lib &&
		cp -v ld/ld-new /tools/bin &&
	
		cd ../ &&
		rm -rf binutils-build;
	}
	build_pkg $pkg_binutils build_binutils
	
	# Ncurses
	function build_ncurses {
		./configure --prefix=/tools --with-shared \
			--without-debug --without-ada --enable-overwrite &&
		make &&
		make install;
	}
	build_pkg $pkg_ncurses build_ncurses
	
	# Bash
	function build_bash {
		patch -Np1 -i ../bash-3.2-fixes-5.patch &&
		./configure --prefix=/tools --without-bash-malloc &&
		make &&
		make install &&
		ln -vs bash /tools/bin/sh;
	}
	build_pkg $pkg_bash build_bash
	
	# Bzip2
	function build_bzip2 {
		make &&
		make PREFIX=/tools install;
	}
	build_pkg $pkg_bzip2 build_bzip2
	
	# Coreutils
	function build_coreutils {
		./configure --prefix=/tools &&
		make &&
		make install && 
		cp -v src/su /tools/bin/su-tools;
	}
	build_pkg $pkg_coreutils build_coreutils
	
	# Diffutils
	function build_diffutils {
		./configure --prefix=/tools &&
		make &&
		make install;
	}
	build_pkg $pkg_diffutils build_diffutils
	
	# Findutils
	function build_findutils {
		./configure --prefix=/tools &&
		make &&
		make install;
	}
	build_pkg $pkg_findutils build_findutils
	
	# Gawk
	function build_gawk {
		./configure --prefix=/tools &&
		echo "#define HAVE_LANGINFO_CODESET 1" >> config.h &&
		echo "#define HAVE_LC_MESSAGES 1" >> config.h &&
		make &&
		make install;
	}
	build_pkg $pkg_gawk build_gawk
	
	# Gettext
	function build_gettext {
		cd gettext-tools &&
		./configure --prefix=/tools --disable-shared &&
		make -C gnulib-lib &&
		make -C src msgfmt &&
		cp -v src/msgfmt /tools/bin;
	}
	build_pkg $pkg_gettext build_gettext
	
	# Grep
	function build_grep {
		./configure --prefix=/tools \
			--disable-perl-regexp &&
		make &&
		make install;
	}
	build_pkg $pkg_grep build_grep
	
	# Gzip
	function build_gzip {
		./configure --prefix=/tools &&
		make &&
		make install;
	}
	build_pkg $pkg_gzip build_gzip
	
	# Make
	function build_make {
		./configure --prefix=/tools &&
		make &&
		make install;
	}
	build_pkg $pkg_make build_make
	
	# Patch
	function build_patch {
		./configure --prefix=/tools &&
		make &&
		make install;
	}
	build_pkg $pkg_patch build_patch
	
	# Perl
	function build_perl {
		patch -Np1 -i ../perl-5.8.8-libc-2.patch &&
		./configure.gnu --prefix=/tools -Dstatic_ext='Data/Dumper Fcntl IO POSIX' &&
		make perl utilities &&
		cp -v perl pod/pod2man /tools/bin &&
		mkdir -pv /tools/lib/perl5/5.8.8 &&
		cp -Rv lib/* /tools/lib/perl5/5.8.8;
	}
	build_pkg $pkg_perl build_perl
	
	# Sed
	function build_sed {
		./configure --prefix=/tools &&
		make &&
		make install;
	}
	build_pkg $pkg_sed build_sed
	
	# Tar
	function build_tar {
		./configure --prefix=/tools &&
		make &&
		make install;
	}
	build_pkg $pkg_tar build_tar
	
	# Texinfo
	function build_texinfo {
		./configure --prefix=/tools &&
		make &&
		make install;
	}
	build_pkg $pkg_texinfo build_texinfo
	
	# Util-linux
	function build_utillinux {
		sed -i 's@/usr/include@/tools/include@g' configure &&
		./configure &&
		make -C lib &&
		make -C mount mount umount &&
		make -C text-utils more &&
		cp -v mount/{,u}mount text-utils/more /tools/bin;
	}
	build_pkg $pkg_utillinux build_utillinux
	
	# Changing ownship
	chown -R root:root $lfsroot/tools
	
	# Perpare virtual filesystems
	mkdir -pv $lfsroot/{dev,proc,sys}
	mknod -m 600 $lfsroot/dev/console c 5 1
	mknod -m 666 $lfsroot/dev/null c 1 3
	mount -v --bind /dev $lfsroot/dev
	mount -vt devpts devpts $lfsroot/dev/pts
	mount -vt tmpfs shm $lfsroot/dev/shm
	mount -vt proc proc $lfsroot/proc
	mount -vt sysfs sysfs $lfsroot/sys
	
	# Enter chroot environment 
	cp -v $scriptfile $lfsroot
	scriptname=$(basename $scriptfile)
	chroot "$lfsroot" /tools/bin/env -i \
		HOME=/root TERM="$TERM" \
		PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin \
		/tools/bin/bash +h /$scriptname --chroot
	exit
}


function build_lfs_system {
	# Setting
	lfsbuild=/sources
	logfile=/lfsbuild.log

	# Creating directies
	mkdir -pv /{bin,boot,etc/opt,home,lib,mnt,opt}
	mkdir -pv /{media/{floppy,cdrom},sbin,srv,var}
	install -dv -m 0750 /root
	install -dv -m 1777 /tmp /var/tmp
	mkdir -pv /usr/{,local/}{bin,include,lib,sbin,src}
	mkdir -pv /usr/{,local/}share/{doc,info,locale,man}
	mkdir -v  /usr/{,local/}share/{misc,terminfo,zoneinfo}
	mkdir -pv /usr/{,local/}share/man/man{1..8}
	for dir in /usr /usr/local; do
		ln -sv share/{man,doc,info} $dir
	done
	mkdir -v /var/{lock,log,mail,run,spool}
	mkdir -pv /var/{opt,cache,lib/{misc,locate},local}
	
	# Create essential files and symlinks
	ln -sv /tools/bin/{bash,cat,echo,grep,pwd,stty} /bin
	ln -sv /tools/bin/perl /usr/bin
	ln -sv /tools/lib/libgcc_s.so{,.1} /usr/lib
	ln -sv /tools/lib/libstdc++.so{,.6} /usr/lib
	ln -sv bash /bin/sh
	touch /etc/mtab
	cp $lfsbuild/conf/{passwd,group} /etc/
	touch /var/run/utmp /var/log/{btmp,lastlog,wtmp}
	chgrp -v utmp /var/run/utmp /var/log/lastlog
	chmod -v 664 /var/run/utmp /var/log/lastlog

	##################################
	# Change filename for compatible #
	##################################
	pkg_vim=vim71.tar.gz
	mv $lfsbuild/vim-7.1.tar.bz2 $lfsbuild/vim71.tar.gz
	pkg_iproute2=iproute-2.6.20-070313.tar.gz
	mv $lfsbuild/iproute2-2.6.20-070313.tar.gz $lfsbuild/iproute-2.6.20-070313.tar.gz 
	##################################
	# End				 #
	##################################
	

	function build_linux {
		sed -i '/scsi/d' include/Kbuild &&
		make mrproper &&
		make headers_check &&
		make INSTALL_HDR_PATH=dest headers_install &&
		cp -rv dest/include/* /usr/include;
	} 
	build_pkg $pkg_linux build_linux

	function build_manpages {
		make install;
	}
	build_pkg $pkg_manpages build_manpages

	function build_glibc {
		tar -xvf ../glibc-libidn-2.5.1.tar.gz &&
		mv glibc-libidn-2.5.1 libidn &&
		sed -i '/vi_VN.TCVN/d' localedata/SUPPORTED &&
		sed -i \
		's|libs -o|libs -L/usr/lib -Wl,-dynamic-linker=/lib/ld-linux.so.2 -o|' \
        	scripts/test-installation.pl &&
		sed -i 's|@BASH@|/bin/bash|' elf/ldd.bash.in &&
		mkdir -v ../glibc-build &&
		cd ../glibc-build &&
		../glibc-2.5.1/configure --prefix=/usr \
    		--disable-profile --enable-add-ons \
    		--enable-kernel=2.6.0 --libexecdir=/usr/lib/glibc &&
		make &&
		touch /etc/ld.so.conf &&
		make install &&
		mkdir -pv /usr/lib/locale &&
		localedef -i de_DE -f ISO-8859-1 de_DE &&
		localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro &&
		localedef -i en_HK -f ISO-8859-1 en_HK &&
		localedef -i en_PH -f ISO-8859-1 en_PH &&
		localedef -i en_US -f ISO-8859-1 en_US &&
		localedef -i en_US -f UTF-8 en_US.UTF-8 &&
		localedef -i es_MX -f ISO-8859-1 es_MX &&
		localedef -i fa_IR -f UTF-8 fa_IR &&
		localedef -i fr_FR -f ISO-8859-1 fr_FR &&
		localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro &&
		localedef -i fr_FR -f UTF-8 fr_FR.UTF-8 &&
		localedef -i it_IT -f ISO-8859-1 it_IT &&
		localedef -i ja_JP -f EUC-JP ja_JP &&
		localedef -i zh_CN -f GB18030 zh_CN.GB18030 &&
		localedef -i zh_CN -f UTF-8 zh_CN.UTF-8 &&
		localedef -i zh_CN -f GB2312 zh_CN.GB2312 &&

		# Configure
		cp -v $lfsbuild/conf/nsswitch.conf /etc/ &&
		cp -v --remove-destination /usr/share/zoneinfo/Asia/Shanghai \
		/etc/localtime &&
		cp -v $lfsbuild/conf/ld.so.conf /etc &&

		cd ../ &&
		rm -rf glibc-build;
				
	}	 
	build_pkg $pkg_glibc build_glibc

	# Readjusting the toolchains
	mv -v /tools/bin/{ld,ld-old}
	mv -v /tools/$(gcc -dumpmachine)/bin/{ld,ld-old}
	mv -v /tools/bin/{ld-new,ld}
	ln -sv /tools/bin/ld /tools/$(gcc -dumpmachine)/bin/ld

	gcc -dumpspecs | sed \
	-e 's@/tools/lib/ld-linux.so.2@/lib/ld-linux.so.2@g' \
	-e '/\*startfile_prefix_spec:/{n;s@.*@/usr/lib/ @}' \
	-e '/\*cpp:/{n;s@$@ -isystem /usr/include@}' > \
	`dirname $(gcc --print-libgcc-file-name)`/specs

	# Binutils
	function build_binutils {
		mkdir -v ../binutils-build &&
		cd ../binutils-build &&
		../binutils-2.17/configure --prefix=/usr \
		--enable-shared &&
		make tooldir=/usr &&
		make tooldir=/usr install &&
		cp -v ../binutils-2.17/include/libiberty.h /usr/include &&
		
		cd ../ &&
		rm -rf ../binutils-build;
	}
	build_pkg $pkg_binutils build_binutils

	# GCC
	function build_gcc {
		sed -i 's/install_to_$(INSTALL_DEST) //' libiberty/Makefile.in &&
		sed -i 's/^XCFLAGS =$/& -fomit-frame-pointer/' gcc/Makefile.in &&
		sed -i 's@\./fixinc\.sh@-c true@' gcc/Makefile.in &&
		sed -i 's/@have_mktemp_command@/yes/' gcc/gccbug.in &&
		mkdir -v ../gcc-build &&
		cd ../gcc-build &&
		../gcc-4.1.2/configure --prefix=/usr \
		--libexecdir=/usr/lib --enable-shared \
		--enable-threads=posix --enable-__cxa_atexit \
		--enable-clocale=gnu --enable-languages=c,c++ &&
		make &&
		make install &&
		ln -sv ../usr/bin/cpp /lib &&
		ln -sv gcc /usr/bin/cc &&

		cd ../ &&
		rm -rf gcc-build;
	}
	build_pkg $pkg_gcc build_gcc

	# Berkey DB
	function build_db {
		patch -Np1 -i ../db-4.5.20-fixes-1.patch &&
		cd build_unix &&
		../dist/configure --prefix=/usr --enable-compat185 --enable-cxx &&
		make &&
		make docdir=/usr/share/doc/db-4.5.20 install &&
		chown -Rv root:root /usr/share/doc/db-4.5.20;
	}
	build_pkg $pkg_db build_db

	# Sed
	function build_sed {
		./configure --prefix=/usr --bindir=/bin --enable-html &&
		make &&
		make install;
	}
	build_pkg $pkg_sed build_sed

	# E2fsprogs
	function build_e2fsprogs {
		sed -i -e 's@/bin/rm@/tools&@' lib/blkid/test_probe.in &&
		mkdir -v build &&
		cd build &&
		../configure --prefix=/usr --with-root-prefix="" \
		--enable-elf-shlibs &&
		make		 &&
		make install &&
		make install-libs;
	}
	build_pkg $pkg_e2fsprogs build_e2fsprogs

	# Coreutils
	function build_coreutils {
		patch -Np1 -i ../coreutils-6.9-uname-1.patch &&
		patch -Np1 -i ../coreutils-6.9-suppress_uptime_kill_su-1.patch &&
		patch -Np1 -i ../coreutils-6.9-i18n-1.patch &&
		chmod +x tests/sort/sort-mb-tests &&
		./configure --prefix=/usr &&
		make &&
		make install &&
		mv -v /usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} /bin &&
		mv -v /usr/bin/{false,hostname,ln,ls,mkdir,mknod,mv,pwd,readlink,rm} /bin &&
		mv -v /usr/bin/{rmdir,stty,sync,true,uname} /bin &&
		mv -v /usr/bin/chroot /usr/sbin &&
		mv -v /usr/bin/{head,sleep,nice} /bin;
	}
	build_pkg $pkg_coreutils build_coreutils

	# Iana-etc
	function build_ianaetc {
		make &&
		make install;
	}
	build_pkg $pkg_ianaetc build_ianaetc

	# M4
	function build_m4 {
		./configure --prefix=/usr &&
		make &&
		make install;
	}
	build_pkg $pkg_m4 build_m4
	
	# Bison
	function build_bison {
		./configure --prefix=/usr &&
		echo '#define YYENABLE_NLS 1' >> config.h &&
		make &&
		make install;
	}
	build_pkg $pkg_bison build_bison

	# Ncurses
	function build_ncurses {
		patch -Np1 -i ../ncurses-5.6-coverity_fixes-1.patch &&
		./configure --prefix=/usr --with-shared --without-debug --enable-widec &&
		make &&
		make install &&
		chmod -v 644 /usr/lib/libncurses++w.a &&
		mv -v /usr/lib/libncursesw.so.5* /lib &&
		ln -sfv ../../lib/libncursesw.so.5 /usr/lib/libncursesw.so &&
		for lib in curses ncurses form panel menu ; do \
			rm -vf /usr/lib/lib${lib}.so ; \
			echo "INPUT(-l${lib}w)" >/usr/lib/lib${lib}.so ; \
			ln -sfv lib${lib}w.a /usr/lib/lib${lib}.a ; \
		done &&
		ln -sfv libncurses++w.a /usr/lib/libncurses++.a &&
		rm -vf /usr/lib/libcursesw.so &&
		echo "INPUT(-lncursesw)" >/usr/lib/libcursesw.so &&
		ln -sfv libncurses.so /usr/lib/libcurses.so &&
		ln -sfv libncursesw.a /usr/lib/libcursesw.a &&
		ln -sfv libncurses.a /usr/lib/libcurses.a;
	}
	build_pkg $pkg_ncurses build_ncurses

	# Procps
	function build_procps {
		make &&
		make install;
	}
	build_pkg $pkg_procps build_procps

	# Libtool
	function build_libtool {
		./configure --prefix=/usr &&
		make &&
		make install;
	}
	build_pkg $pkg_libtool build_libtool

	# Perl
	function build_perl {
		echo "127.0.0.1 localhost $(hostname)" > /etc/hosts &&
		./configure.gnu --prefix=/usr \
		-Dman1dir=/usr/share/man/man1 \
		-Dman3dir=/usr/share/man/man3 \
		-Dpager="/usr/bin/less -isR" &&
		make &&
		make install;
	}
	build_pkg $pkg_perl build_perl

	# Readline
	function build_readline {
		sed -i '/MV.*old/d' Makefile.in &&
		sed -i '/{OLDSUFF}/c:' support/shlib-install &&
		patch -Np1 -i ../readline-5.2-fixes-3.patch &&
		./configure --prefix=/usr --libdir=/lib &&
		make install &&
		mv -v /lib/lib{readline,history}.a /usr/lib &&
		rm -v /lib/lib{readline,history}.so &&
		ln -sfv ../../lib/libreadline.so.5 /usr/lib/libreadline.so &&
		ln -sfv ../../lib/libhistory.so.5 /usr/lib/libhistory.so;
	}
	build_pkg $pkg_readline build_readline

	# Zlib
	function build_zlib {
		./configure --prefix=/usr --shared --libdir=/lib &&
		make &&
		make install &&
		rm -v /lib/libz.so &&
		ln -sfv ../../lib/libz.so.1.2.3 /usr/lib/libz.so &&
		make clean &&
		./configure --prefix=/usr &&
		make &&
		make install &&
		chmod -v 644 /usr/lib/libz.a;
	}
	build_pkg $pkg_zlib build_zlib
	
	# Autoconf
	function build_autoconf {
		./configure --prefix=/usr &&
		make &&
		make install;
	}
	build_pkg $pkg_autoconf build_autoconf

	# Automake
	function build_automake {
		./configure --prefix=/usr &&
		make &&
		make install;
	}
	build_pkg $pkg_automake build_automake

	# Bash
	function build_bash {
		tar -xvf ../bash-doc-3.2.tar.gz &&
		sed -i "s|htmldir = @htmldir@|htmldir = /usr/share/doc/bash-3.2|" \
		Makefile.in &&
		patch -Np1 -i ../bash-3.2-fixes-5.patch &&
		./configure --prefix=/usr --bindir=/bin \
		--without-bash-malloc --with-installed-readline &&
		make &&
		make install;
	}	
	build_pkg $pkg_bash build_bash

	# Bzip2
	function build_bzip2 {
		patch -Np1 -i ../bzip2-1.0.4-install_docs-1.patch &&
		make -f Makefile-libbz2_so &&
		make clean &&
		make &&
		make PREFIX=/usr install &&
		cp -v bzip2-shared /bin/bzip2 &&
		cp -av libbz2.so* /lib &&
		ln -sv ../../lib/libbz2.so.1.0 /usr/lib/libbz2.so &&
		rm -v /usr/bin/{bunzip2,bzcat,bzip2} &&
		ln -sv bzip2 /bin/bunzip2 &&
		ln -sv bzip2 /bin/bzcat;
	}
	build_pkg $pkg_bzip2 build_bzip2

	# Diffutils
	function build_diffutils {
		patch -Np1 -i ../diffutils-2.8.1-i18n-1.patch &&
		touch man/diff.1 &&
		./configure --prefix=/usr &&
		make &&
		make install;
	}
	build_pkg $pkg_diffutils build_diffutils

	# File
	function build_file {
		./configure --prefix=/usr &&
		make &&
		make install;
	}
	build_pkg $pkg_file build_file

	# Findutils
	function build_findutils {
		./configure --prefix=/usr --libexecdir=/usr/lib/findutils \
		--localstatedir=/var/lib/locate &&
		make &&
		make install &&
		mv -v /usr/bin/find /bin &&
		sed -i -e 's/find:=${BINDIR}/find:=\/bin/' /usr/bin/updatedb;
	}
	build_pkg $pkg_findutils build_findutils

	# Flex
	function build_flex {
		./configure --prefix=/usr &&
		make &&
		make install &&
		ln -sv libfl.a /usr/lib/libl.a &&
		echo 'exec /usr/bin/flex -l "$@"' > /usr/bin/lex &&
		chmod -v 755 /usr/bin/lex;
	}
	build_pkg $pkg_flex build_flex

	# Grub
	function build_grub {
		patch -Np1 -i ../grub-0.97-disk_geometry-1.patch &&
		./configure --prefix=/usr &&
		make &&
		make install &&
		mkdir -v /boot/grub &&
		cp -v /usr/lib/grub/i386-pc/stage{1,2} /boot/grub &&
		cp -v /usr/lib/grub/i386-pc/e2fs_stage1_5 /boot/grub;
	}
	build_pkg $pkg_grub build_grub

	# Gawk
	function build_gawk {
		patch -Np1 -i ../gawk-3.1.5-segfault_fix-1.patch &&
		./configure --prefix=/usr --libexecdir=/usr/lib &&
		echo '#define HAVE_LANGINFO_CODESET 1' >> config.h &&
		echo '#define HAVE_LC_MESSAGES 1' >> config.h &&
		make  &&
		make install;
	}
	build_pkg $pkg_gawk build_gawk

	# Gettext
	function build_gettext {
		./configure --prefix=/usr &&
		make &&
		make install;
	}
	build_pkg $pkg_gettext build_gettext

	# Grep 
	function build_grep {
		patch -Np1 -i ../grep-2.5.1a-redhat_fixes-2.patch &&
		chmod +x tests/fmbtest.sh &&
		./configure --prefix=/usr --bindir=/bin &&
		make &&
		make install;
	}	
	build_pkg $pkg_grep build_grep

	# Groff
	function build_groff {
		patch -Np1 -i ../groff-1.18.1.4-debian_fixes-1.patch &&
		sed -i -e 's/2010/002D/' -e 's/2212/002D/' \
		-e 's/2018/0060/' -e 's/2019/0027/' font/devutf8/R.proto &&
		PAGE=A4 ./configure --prefix=/usr --enable-multibyte &&
		make &&
		make install &&
		ln -sv eqn /usr/bin/geqn &&
		ln -sv tbl /usr/bin/gtbl;
	}
	build_pkg $pkg_groff build_groff

	# Gzip
	function build_gzip {
		./configure --prefix=/usr --bindir=/bin &&
		make &&
		make install &&
		mv -v /bin/{gzexe,uncompress,zcmp,zdiff,zegrep} /usr/bin &&
		mv -v /bin/{zfgrep,zforce,zgrep,zless,zmore,znew} /usr/bin;
	}
	build_pkg $pkg_gzip build_gzip

	# Inetutils
	function build_inetutils {
		patch -Np1 -i ../inetutils-1.5-no_server_man_pages-2.patch &&
		./configure --prefix=/usr --libexecdir=/usr/sbin \
		--sysconfdir=/etc --localstatedir=/var \
		--disable-ifconfig --disable-logger --disable-syslogd \
		--disable-whois --disable-servers &&
		make &&
		make install &&
		mv -v /usr/bin/ping /bin;
	}
	build_pkg $pkg_inetutils build_inetutils

	# IPRoute2
	function build_iproute2 {	
		sed -i -e '/tc-bfifo.8/d' -e '/tc-pfifo.8/s/pbfifo/bfifo/' Makefile &&
		make SBINDIR=/sbin &&
		make SBINDIR=/sbin install &&
		mv -v /sbin/arpd /usr/sbin;
	}
	build_pkg $pkg_iproute2 build_iproute2

	# Kbd
	function build_kbd {
		patch -Np1 -i ../kbd-1.12-backspace-1.patch &&
		patch -Np1 -i ../kbd-1.12-gcc4_fixes-1.patch &&
		./configure --datadir=/lib/kbd &&
		make &&
		make install &&
		mv -v /usr/bin/{kbd_mode,openvt,setfont} /bin;
	}
	build_pkg $pkg_kbd build_kbd

	# Less
	function build_less {
		./configure --prefix=/usr --sysconfdir=/etc &&
		make &&
		make install;
	}
	build_pkg $pkg_less build_less

	# Make
	function build_make {
		./configure --prefix=/usr &&
		make &&
		make install;
	}
	build_pkg $pkg_make build_make

	# Man-DB
	function build_mandb {
		mv man/de{_DE.88591,} &&
		mv man/es{_ES.88591,} &&
		mv man/it{_IT.88591,} &&
		mv man/ja{_JP.eucJP,} &&
		sed -i 's,\*_\*,??,' man/Makefile.in &&
		sed -i -e '\%\t/usr/man%d' -e '\%\t/usr/local/man%d' src/man_db.conf.in &&
		echo '#define WEB_BROWSER "exec /usr/bin/lynx"' >> include/manconfig.h &&
		echo '#define COL "/usr/bin/col"' >> include/manconfig.h &&
		echo '#define VGRIND "/usr/bin/vgrind"' >> include/manconfig.h &&
		echo '#define GRAP "/usr/bin/grap"' >> include/manconfig.h &&
		patch -Np1 -i ../man-db-2.4.4-fixes-1.patch &&
		./configure --prefix=/usr --enable-mb-groff --disable-setuid &&
		make &&
		make install &&
		install -m755 $lfsbuild/conf/convert-mans  /usr/bin;
	}
	build_pkg $pkg_mandb build_mandb

	# Mktemp
	function build_mktemp {
		patch -Np1 -i ../mktemp-1.5-add_tempfile-3.patch &&
		./configure --prefix=/usr --with-libc &&
		make &&
		make install &&
		make install-tempfile;
	}
	build_pkg $pkg_mktemp build_mktemp

	# Module-Init-Tools
	function build_moduleinittools {
		patch -Np1 -i ../module-init-tools-3.2.2-modprobe-1.patch &&
		./configure --prefix=/ --enable-zlib &&
		make &&
		make INSTALL=install install;
	} 
	build_pkg $pkg_moduleinittools build_moduleinittools

	# Patch 
	function build_patch {
		./configure --prefix=/usr &&
		make &&
		make install;
	}
	build_pkg $pkg_patch build_patch

	# Psmisc
	function build_psmisc {
		./configure --prefix=/usr --exec-prefix="" &&
		make &&
		make install &&
		mv -v /bin/pstree* /usr/bin;
	}
	build_pkg $pkg_psmisc build_psmisc

	# Shadow
	function build_shadow {
		patch -Np1 -i ../shadow-4.0.18.1-useradd_fix-2.patch &&
		./configure --libdir=/lib --sysconfdir=/etc --enable-shared \
		--without-selinux &&
		sed -i 's/groups$(EXEEXT) //' src/Makefile &&
		find man -name Makefile -exec sed -i 's/groups\.1 / /' {} \; &&
		for i in de es fi fr id it pt_BR ; do
			convert-mans UTF-8 ISO-8859-1 man/${i}/*.? 
		done &&
		for i in cs hu pl; do
			convert-mans UTF-8 ISO-8859-2 man/${i}/*.? 
		done &&
		convert-mans UTF-8 EUC-JP man/ja/*.? &&
		convert-mans UTF-8 KOI8-R man/ru/*.? &&
		convert-mans UTF-8 ISO-8859-9 man/tr/*.? &&
		convert-mans UTF-8 GB2312 man/zh_CN/*.? &&
		sed -i -e 's@#MD5_CRYPT_ENAB.no@MD5_CRYPT_ENAB yes@' \
		-e 's@/var/spool/mail@/var/mail@' etc/login.defs &&
		make &&
		make install &&
		mv -v /usr/bin/passwd /bin &&
		mv -v /lib/libshadow.*a /usr/lib &&
		rm -v /lib/libshadow.so &&
		ln -sfv ../../lib/libshadow.so.0 /usr/lib/libshadow.so &&
		pwconv &&
		grpconv &&
		useradd -D -b /home &&
		sed -i 's/yes/no/' /etc/default/useradd;
	}
	build_pkg $pkg_shadow build_shadow

	# Sysklogd
	function build_sysklogd {
		patch -Np1 -i ../sysklogd-1.4.1-fixes-2.patch &&
		patch -Np1 -i ../sysklogd-1.4.1-8bit-1.patch &&
		make &&
		make install &&
		cp -v $lfsbuild/conf/syslog.conf /etc/;
	}
	build_pkg $pkg_sysklogd build_sysklogd


	# Sysvinit
	function build_sysvinit {
		sed -i 's@Sending processes@& configured via /etc/inittab@g' \
		src/init.c &&
		make -C src &&
		make -C src install &&
		cp -v $lfsbuild/conf/inittab /etc/;
	}
	build_pkg $pkg_sysvinit build_sysvinit

	# Tar
	function build_tar {
		./configure --prefix=/usr --bindir=/bin --libexecdir=/usr/sbin &&
		make &&
		make install;
	}
	build_pkg $pkg_tar build_tar

	# Texinfo 
	function build_texinfo {
		patch -Np1 -i ../texinfo-4.9-multibyte-1.patch &&
		patch -Np1 -i ../texinfo-4.9-tempfile_fix-1.patch &&
		./configure --prefix=/usr &&
		make &&
		make install &&
		make TEXMF=/usr/share/texmf install-tex;
	} 
	build_pkg $pkg_texinfo build_texinfo

	# Udev
	function build_udev {	
		tar -xvf ../udev-config-6.3.tar.bz2 &&
		install -dv /lib/{firmware,udev/devices/{pts,shm}} &&
		mknod -m0666 /lib/udev/devices/null c 1 3 &&
		ln -sv /proc/self/fd /lib/udev/devices/fd &&
		ln -sv /proc/self/fd/0 /lib/udev/devices/stdin &&
		ln -sv /proc/self/fd/1 /lib/udev/devices/stdout &&
		ln -sv /proc/self/fd/2 /lib/udev/devices/stderr &&
		ln -sv /proc/kcore /lib/udev/devices/core &&
		make EXTRAS="`echo extras/*/`" &&
		make DESTDIR=/ EXTRAS="`echo extras/*/`" install  &&
		cp -v etc/udev/rules.d/[0-9]* /etc/udev/rules.d/ &&
		cd udev-config-6.3 &&
		make install &&
		make install-doc &&
		make install-extra-doc &&
		cd .. &&
		install -m644 -v docs/writing_udev_rules/index.html \
		/usr/share/doc/udev-113/index.html;
	}
	build_pkg $pkg_udev build_udev

	# Utils-linux 
	function build_utillinux {
		sed -e 's@etc/adjtime@var/lib/hwclock/adjtime@g' \
		-i $(grep -rl '/etc/adjtime' .) &&
		mkdir -pv /var/lib/hwclock &&
		patch -Np1 -i ../util-linux-2.12r-cramfs-1.patch &&
		patch -Np1 -i ../util-linux-2.12r-lseek-1.patch &&
		./configure &&
		make HAVE_KILL=yes HAVE_SLN=yes &&
		make HAVE_KILL=yes HAVE_SLN=yes install;
	}
	build_pkg $pkg_utillinux build_utillinux

	# Vim
	function build_vim {
		tar zxvf ../vim-7.1-lang.tar.gz -C ../ &&
		patch -Np1 -i ../vim-7.1-fixes-1.patch &&
		patch -Np1 -i ../vim-7.1-mandir-1.patch &&
		echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h &&
		./configure --prefix=/usr --enable-multibyte &&
		make &&
		make install &&
		ln -sv vim /usr/bin/vi &&
		for L in "" fr it pl ru; do
			ln -sv vim.1 /usr/share/man/$L/man1/vi.1 
		done &&
		ln -sv ../vim/vim71/doc /usr/share/doc/vim-7.1 &&
		cp -v $lfsbuild/conf/vimrc /etc/;
	}
	build_pkg $pkg_vim build_vim

	# /tools is no longer needed
	PATH=/bin:/usr/bin:/sbin:/usr/sbin

	# LFS-Bootscripts
	function build_lfsbootscripts {
		make install
	}
	build_pkg $pkg_lfsbootscripts build_lfsbootscripts

	# Configure setclock script
	cp -v $lfsbuild/conf/clock /etc/sysconfig/

	# Configure /etc/inputrc
	cp -v $lfsbuild/conf/inputrc /etc/

	# Configure bash profile
	cp -v $lfsbuild/conf/profile /etc/

	# Configure the hostname
	echo "HOSTNAME=$hostname" > /etc/sysconfig/network	

	# Configure the network interface
	mkdir -v /etc/sysconfig/network-devices/ifconfig.eth0
	sed -i "s/<ipaddr>/$ipaddr/" $lfsbuild/conf/ipv4
	sed -i "s/<gateway>/$gateway/" $lfsbuild/conf/ipv4
	sed -i "s/<netmask>/$netmask/" $lfsbuild/conf/ipv4
	sed -i "s/<broadcast>/$broadcast/" $lfsbuild/conf/ipv4
	cp -v $lfsbuild/conf/ipv4 /etc/sysconfig/network-devices/ifconfig.eth0/
	sed -i "s/<dnsserv>/$dnsserv/" $lfsbuild/conf/resolv.conf
	cp -v $lfsbuild/conf/resolv.conf /etc/

	# Configure /etc/fstab
	sed -i "s@<root>@$rootfs@" $lfsbuild/conf/fstab
	sed -i "s@<home>@$homefs@" $lfsbuild/conf/fstab
	sed -i "s@<swap>@$swapfs@" $lfsbuild/conf/fstab
	cp -v $lfsbuild/conf/fstab /etc/

	# Linux kernel
	function build_linux {
		make mrproper &&
		cp -v $lfsbuild/conf/config ./.config &&
		make &&
		cp -v $lfsbuild/conf/modprobe.conf /etc/ &&
		make modules_install &&
		cp -v arch/i386/boot/bzImage /boot/lfskernel-2.6.22.5 &&
		cp -v System.map /boot/System.map-2.6.22.5 &&
		cp -v .config /boot/config-2.6.22.5 &&
		install -d /usr/share/doc/linux-2.6.22.5 &&
		cp -r Documentation/* /usr/share/doc/linux-2.6.22.5;
	}		
	build_pkg $pkg_linux build_linux

	# Setting up Grub
	grubboot=`echo $rootfs |sed  -e 's/^[s|h]d//'  -e 's/[0-9]//g' | tr a-z 0-9`
	sed -i "s@<boot>@$grubboot@g" $lfsbuild/conf/grub-batch
	grub --batch < $lfsbuild/conf/grub-batch
	cp -v $lfsbuild/conf/menu.lst /boot/grub
	mkdir -v /etc/grub
	ln -sv /boot/grub/menu.lst /etc/grub

	# End
	passwd root
	echo 6.3 > /etc/lfs-release	
	exit 
}

if [ $1 ]; then
	if [ $1 = '--chroot' ]; then
		build_lfs_system
	else 
		echo usage
	fi
else
	build_temporary_system
fi
