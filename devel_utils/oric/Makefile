.PHONY : all clean

CC=gcc
COMPFLAGS=-O6 -Wall -W -Wstrict-prototypes -Wshadow -Wmissing-declarations -Wmissing-prototypes -fomit-frame-pointer
#BeOS header stdint.h doesn't like -ansi (C++ comments)

# list of applications
APPS=bin2tap tap2dsk old2mfm
OLDAPPS=

all : $(APPS)

clean :
	-rm $(APPS)

$(APPS) : Makefile

# Rules
% : %.c ; $(CC) $< -o $@ $(COMPFLAGS)
