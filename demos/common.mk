#cc65 is in my $PATH.  If it isn't in yours, adjust for your system
AS	= ca65
LD	= ld65 
LDFLAGS = -C nes.ld -m $(ROM).map
OBJDUMP = od65

#put whatever emulator you use here.  Mednafen is in my $PATH, so...
DEBUGGER = mednafen

BIN	= $(ROM).nes

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
	echo 'Mednafen - Hold Alt-D to enter debugger.' 
	echo 'Press any key to continue to execute the rom' 
	$(DEBUGGER) -nes.enable 1 $(BIN) 

#I'm on Linux, so I moved fceux Windows version in my projects path.  Linux version doesn't have debugger
debug:
	~/Projects/6502/famicom/a_tools/fceuxw/fceux.exe ./$(BIN)

