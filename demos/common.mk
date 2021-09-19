#!/bin/sh


BIN	= $(NAME).nes

AS	= ca65
LD	= ld65 
DA  = da65

extract = ./../../tools/nesextract
radare2 = ./../../tools/rasm2

LDFLAGS = -C nes.cfg -m $(NAME).map
OBJDUMP = od65
DEBUGGER = fceux

SS=$(wildcard *.s)
OBJS=$(SS:.s=.o)

all:	$(BIN)

clean:
	rm -f $(BIN) $(shell find . -name '*.o')
	rm -f *.map *.dump disassembly

$(BIN): $(OBJS)
	$(LD) -o $(BIN) $(LDFLAGS) $^ 

disassemble:
	$(extract) $(BIN)  
	$(DA) --cpu 6502 --start-addr '$$8000' PRG.prg >| program.s
	${radare2} -a 6502 -D -B -o 32752 -f $(BIN) >| disassembly 

dump: 
	$(OBJDUMP) --dump-all $(OBJS) > $(NAME).dump

run:
	$(DEBUGGER) ./$(BIN)

