# compile switches:
# =================
#  look into the machine specific config.h for details on compile switches.
#  (eg. kernel/c64/config.h)

COMPFLAGS=

# selection of target machine
# ===========================
#
# MACHINE=c64 to create Commodore64 version (binaries in bin64)
# MACHINE=c128 for Commodore128 version (binaries in bin128)
# MACHINE=atari for Atari 65XE/800/130 version (no binaries right now)
# MACHINE=oric for ORIC-1/Atmos/Telestrat version (no binaries right now)

#MACHINE=c64
MACHINE=oric

# Modules to include in package (created with "make package")

#MODULES=sswiftlink sfifo64 rs232std swiftlink fifo64
MODULES=

# Applications to include in package
# the applications (in binary form) do not depend on the machine selection

APPS=getty lsmod microterm ps sh sleep testapp wc cat tee uuencode \
     uudecode 232echo 232term kill rm ls buf cp uptime time meminfo \
     strminfo uname more beep help env date ciartc dcf77 smwrtc \
     hextype clear true false echo touch expand \
     b-co b-cs ide64rtc cd pwd
	         
# Test Applications

TAPPS=amalloc

# Scripts

SAPPS=dir man hello.sh sysinfo sysinfo.sh

# Internet Applications
# will be put in the same package als APPS now, but may go into a
# seperate one, in case the APP-package grows to big

IAPPS=connd ftp tcpipstat tcpip ppp loop slip httpd telnet popclient

#============== end of configurable section ============================

.PHONY : all apps kernel libstd help package clean distclean devel

# shouldn't we use $(CURDIR) instead of $(PWD) ???
export PATH+=:$(PWD)/devel_utils/:$(PWD)/devel_utils/$(MACHINE):.:/bin
export LUPO_INCLUDEPATH=:$(PWD)/kernel:$(PWD)/include
export LNG_LIBRARIES=$(PWD)/lib/libstd.a
export COMPFLAGS
export MACHINE

ifeq "$(filter c64 c128,$(MACHINE))" ""
    BINDIR=bin$(MACHINE)
else
    BINDIR=$(patsubst c%,bin%,$(MACHINE))
endif

ifeq "$(MACHINE)" "atari"
all : kernel
else
all : kernel libstd apps help
endif

apps : devel kernel libstd
	$(MAKE) -C apps

samples : devel libstd
	-$(MAKE) -C samples

kernel : devel
	-rm -f include/config.h
	$(MAKE) -C kernel

libstd : devel
	$(MAKE) -C lib

help :
	$(MAKE) -C help

devel :
	$(MAKE) -C devel_utils
# also build machine-specific dev utils
ifneq "$(wildcard devel_utils/$(MACHINE))" ""
	$(MAKE) -C devel_utils/$(MACHINE)
endif

binaries: all
	-mkdir -p $(BINDIR)
	-cp kernel/boot.$(MACHINE) kernel/lunix.$(MACHINE) $(MODULES:%=kernel/modules/%) $(BINDIR)

cbmpackage : binaries
	-mkdir pkg
	cd $(BINDIR) ; mksfxpkg $(MACHINE) ../pkg/core.$(MACHINE) \
           "*loader" boot.$(MACHINE) lunix.$(MACHINE) $(MODULES)
	cd apps ; mksfxpkg $(MACHINE) ../pkg/apps.$(MACHINE) $(APPS) $(IAPPS)
	cd help ; mksfxpkg $(MACHINE) ../pkg/help.$(MACHINE) *.html
	cd scripts ; mksfxpkg $(MACHINE) ../pkg/scripts.$(MACHINE) $(SAPPS)
	echo "The following may fail"
	-cd samples ; \
	 cp --target-directory=. luna/skeleton ca65/skeleton.o65 cc65/hello ; \
	 mksfxpkg $(MACHINE) ../pkg/samples.$(MACHINE) skeleton skeleton.o65 hello ; \
	 rm skeleton skeleton.o65 hello

cbmdisc: binaries
	echo creating LUnix disc image for $(MACHINE)
	c1541 -format lunix,00 d64 lunix-$(MACHINE).d64 > /dev/null

	cd $(BINDIR); for i in \
		loader fasthead fastloader \
		boot.$(MACHINE) lunix.$(MACHINE) $(MODULES) \
		; do c1541 -attach ../lunix-$(MACHINE).d64 -write $$i > /dev/null \
		; done

	cd kernel; for i in \
		lunixrc \
		; do c1541 -attach ../lunix-$(MACHINE).d64 -write $$i .$$i > /dev/null \
		; done

	cd apps; for i in \
		$(APPS) $(IAPPS) $(TAPPS) \
		; do c1541 -attach ../lunix-$(MACHINE).d64 -write $$i > /dev/null \
		; done

	cd help; for i in \
		*.html \
		; do c1541 -attach ../lunix-$(MACHINE).d64 -write $$i > /dev/null \
		; done

	cd scripts; for i in \
		$(SAPPS) \
		; do c1541 -attach ../lunix-$(MACHINE).d64 -write $$i > /dev/null \
		; done

ataripackage: binaries
	makeimage $(BINDIR)/boot.$(MACHINE) $(BINDIR)/lunix.$(MACHINE) $(BINDIR)/atari.bin
	cp $(BINDIR)/atari.bin pkg

ataridisc: binaries
	makeatr lng-$(MACHINE).atr $(BINDIR)/atari.bin

oricpackage: oricdisc
	zip -jy9 lunix-oric-alpha.zip $(BINDIR)/lunix.tap $(BINDIR)/lunix.dsk

# BeOS doesn't use the updated PATH before execing...
# give full path
oricdisc: binaries
	echo "test test"> $(BINDIR)/test.txt
	devel_utils/$(MACHINE)/bin2tap -c -n lunix $(BINDIR)/lunix.$(MACHINE) \
		-a -n lboot $(BINDIR)/boot.$(MACHINE) \
		$(BINDIR)/lunix.tap
#		-s 0 -n test $(BINDIR)/test.txt 
	rm -f $(BINDIR)/lunix.dsk
	devel_utils/$(MACHINE)/tap2dsk $(BINDIR)/lunix.tap $(BINDIR)/lunix.dsk
	devel_utils/$(MACHINE)/old2mfm $(BINDIR)/lunix.dsk

c64disc c128disc: cbmdisc
c64package c128package: cbmpackage

disc: $(MACHINE)disc
package: $(MACHINE)package

clean :
	$(MAKE) -C kernel clean
	$(MAKE) -C apps clean
	$(MAKE) -C lib clean
	$(MAKE) -C help clean
	$(MAKE) -C samples clean

distclean : clean
	$(MAKE) -C kernel distclean
	$(MAKE) -C devel_utils clean
	$(MAKE) -C devel_utils/apple clean
	$(MAKE) -C devel_utils/atari clean
	$(MAKE) -C devel_utils/oric clean
	-cd kernel ; rm -f boot.c* lunix.c* globals.txt
	-cd bin64 ; rm -f $(MODULES) boot.* lunix.* lng.c64
	-cd bin128 ;  rm -f $(MODULES) boot.* lunix.* lng.c128
	-cd binapple ;  rm -f $(MODULES) boot.* lunix.* lng.apple
	-cd binatari ;  rm -f $(MODULES) boot.* lunix.* lng.atari
	-cd binoric ;  rm -f $(MODULES) boot.* lunix.* lng.oric
	-cd include ; rm -f jumptab.h jumptab.ca65.h ksym.h zp.h
	-rm -rf pkg binatari
	find . -name "*~" -exec rm -v \{\} \;
	find . -name "#*" -exec rm -v \{\} \;
