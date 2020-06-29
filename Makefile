#!/bin/make -f

CCFLAGS ?= -Wno-unused-variable

## Reply Transaction Type
## uncomment one only one
## comment both to use automatic detection
#CCFLAGS += -DTT_DDC
#CCFLAGS += -DTT_SIMPLE

## Uncomment to use an external app 'OSDisplay' to have a BezelUI-like OSD
##  provided by https://github.com/zulu-entertainment/OSDisplay
CCFLAGS += -DOSD

all: clean ddcctl

intel nvidia: CCFLAGS += -DkDDCMinReplyDelay=1
intel nvidia: all

amd: CCFLAGS += -DkDDCMinReplyDelay=30000000
amd: all

debug: CCFLAGS += -DDEBUG
debug: clean ddcctl

%.o: %.c
	$(CC) -Wall $(CCFLAGS) -c -o $@ $<

ddcctl: DDC.o
	$(CC) -Wall $(CCFLAGS) -o $@ -lobjc -framework IOKit -framework AppKit -framework Foundation $< $@.m

install: ddcctl
        if [[ ! -d '/usr/local/Cellar/ddcctl/0.1/bin' ]]; then
	    mkdir -p '/usr/local/Cellar/ddcctl/0.1/bin'
	fi
	install ddcctl /usr/local/Cellar/ddcctl/0.1/bin/

clean:
	$(RM) *.o ddcctl

framebuffers:
	ioreg -c IOFramebuffer -k IOFBI2CInterfaceIDs -b -f -l -r -d 1

displaylist:
	ioreg -c IODisplayConnect -b -f -r -l -i -d 2

.PHONY: all clean install displaylist amd intel nvidia
