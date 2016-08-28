# -*- make -*-

# machine-specific 
ifeq "$(MACHINE)" "c64"
    # List of built-in filesystems
    FILESYSTEMS=iec ide64
    # List of modules
    MODULES=sswiftlink sfifo64 rs232std swiftlink fifo64
    # start address of bootloader, do not touch
    START_ADDRESS=4096
endif

ifeq "$(MACHINE)" "c128"
    FILESYSTEMS=iec ide64
    MODULES=sswiftlink sfifo64 rs232std swiftlink fifo64
    START_ADDRESS=4864
endif

ifeq "$(MACHINE)" "atari"
    MODULES=
    START_ADDRESS=20480
endif

ifeq "$(MACHINE)" "oric"
    FILESYSTEMS=iec ide64 oricvtape
    MODULES=
    START_ADDRESS=4096
endif

#============== end of configurable section ============================

.PHONY : all modules clean distclean

export LUPO_INCLUDEPATH=../include
VPATH=$(LUPO_INCLUDEPATH)

KINCLUDES=config.h $(MACHINE).h system.h kerrors.h \
	ikernel.h keyboard.h debug.h zp.h

BINCLUDES=ksym.h $(KINCLUDES)

KERNEL=lunix.$(MACHINE)
BOOT=boot.$(MACHINE)
BOOTEXTRASRC:=$(wildcard $(patsubst %,fs_%_init.s, $(FILESYSTEMS)))
BOOTEXTRA:=$(BOOTEXTRASRC:s=o)
FILESYSTEMS:=$(patsubst %,fs_%.o, $(FILESYSTEMS))
MODULES:=$(addprefix modules/,$(MODULES))

# List of objects (for "lunix.*")
OBJ=init.o delay.o hook.o keyboard.o lock.o panic.o \
    schedule.o sleep.o suspend.o tasksw.o nmi.o console.o error.o \
    imemory.o addtask.o taskctrl.o signal.o smb.o environment.o \
    fs.o fs_pipe.o $(FILESYSTEMS) fs_cons.o fs_user.o fs_sys.o \
    reloc.o kfunc_tab.o o65.o execute.o module.o misc.o

# Boot-loader objects (for "boot.*")
BOOTOBJ=bootstrap.o calib.o $(BOOTEXTRA)

all : $(KERNEL) $(BOOT) modules lng_kfunc.txt

# Rules
%.o : %.s ; luna -qOo $@ $< $(COMPFLAGS)
%   : %.s ; luna -qRo $@ $< $(COMPFLAGS)

# Additional dependencies
$(OBJ)	    : $(KINCLUDES) Makefile
$(BOOTOBJ)  : $(BINCLUDES) Makefile
$(MODULES)  : system.h stdio.h jumptab.h Makefile
console.o   : opt/*_console*.s
keyboard.o  : $(MACHINE)/keyboard.s
bootstrap.o : $(MACHINE)/reset.s $(MACHINE)/irqinit.s $(MACHINE)/reboot.s \
	      $(MACHINE)/initmemmap.s $(MACHINE)/keyboard_init.s \
	      opt/*_console*_init.s boot_extra.h

# Additional compile flags
$(OBJ)      : ECOMPFLAGS=-dBUILDING_KERNEL=1 -d__KERNEL__=1
$(BOOTOBJ)  : ECOMPFLAGS=-dBUILDING_BOOT=1 -d__KERNEL__=1 -d__BOOT__=1
$(MODULES)  : ECOMPFLAGS=-dBUILDING_MODULE=1
BUILD_DATE=$(shell date +'%b %d %Y')
# my gnu make crashes with += above
COMPFLAGS+=$(ECOMPFLAGS) -d__DATE__='"\"$(BUILD_DATE)\""'

# Copy configuration file.
../include/config.h : $(MACHINE)/config.h
	cp $< $@

# Jump-table header file
../include/jumptab.h : kfunc_tab.s
	mkjumptab_h

# zp.h : $(OBJ:o=s) ../include/config.h
# The above would be correct, but would trigger a total rebuild,
# on every small code-change.
../include/zp.h : ../include/config.h
	mkzp_h $(OBJ:o=s)

# Final step of creating the kernel (linking all objects)
$(KERNEL) : $(OBJ)
	lld -d globals.txt -o $@ -s 8192 $^

../include/boot_extra.h : $(BOOTEXTRASRC)
	echo $(BOOTEXTRA)
	grep -h CallFromBootLoader $(BOOTEXTRA:o=s) > ../include/boot_extra.h

# Collect kernel symbols (needed by boot loader).
../include/ksym.h : $(KERNEL) globals.txt
	mksym

# Final step of creating the boot loader (linking all objects)

$(BOOT) : $(BOOTOBJ)
	lld -o $@ -s $(START_ADDRESS) $^

modules : $(MODULES)

lng_kfunc.txt : *.s
	#relate $+ > $@
	echo FIXME LNG_KFUNC.TXT RELATE disables

clean :
	$(RM) *.o

distclean : clean
	$(RM) ../include/config.h ../include/zp.h ../include/jumptab.h \
	  ../include/ksym.h lunix.c* boot.c* lunix.atari boot.atari $(MODULES) \
	  globals.txt lng_kfunc.txt
