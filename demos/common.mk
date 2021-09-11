#!/bin/sh


BIN	= $(ROM).nes

AS	= ca65
LD	= ld65 

LDFLAGS = -C nes.cfg -m $(ROM).map
OBJDUMP = od65
DEBUGGER = fceux

SS=$(wildcard *.s)
OBJS=$(SS:.s=.o)

all:	$(BIN)

clean:
	rm -f $(BIN) && rm -f $(shell find . -name '*.o')  && rm -f *.map && rm -f *.dump

$(BIN): $(OBJS)
	$(LD) $(LDFLAGS) $< -o $@ 

%.o: %.s 
	$(AS) $< -o $@

dump: 
	$(OBJDUMP) --dump-all $(OBJS) > $(ROM).dump

run:
	$(DEBUGGER) ./$(BIN)

