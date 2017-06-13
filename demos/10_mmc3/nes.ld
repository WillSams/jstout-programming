MEMORY {
	# Work RAM
	ZP:     start = $0000, size = $0100, type = rw;
	STACK:  start = $0100, size = $0100, type = rw;
	RAM:    start = $0200, size = $0600, type = rw;

	# NES Cartridge Header
	HEADER: start = $0000, size = $0010, type = ro,  file = %O,, fill = yes, fillval = $00;

	# Program Banks
	BANK00: start = $C000, size = $2000, type = ro,  file = %O,, fill = yes, fillval = $FF;
	BANK01: start = $E000, size = $2000, type = ro,  file = %O,, fill = yes, fillval = $FF;

	# Character Banks
	CHAR00: start = $0000, size = $4000, type = ro,  file = %O,, fill = yes, fillval = $00;
}

SEGMENTS {
	ZEROPAGE: load = ZP,     type = zp;
	SPRITE:   load = RAM,    type = bss, start = $0200, define = yes;
	PALETTE:  load = RAM,    type = bss, start = $0300, define = yes;
	BUFFER:   load = RAM,    type = bss, start = $0320, define = yes;
	DATA:     load = RAM,    type = bss, start = $0400, define = yes;
	HEADER:   load = HEADER, type = ro;
	BANK_00:  load = BANK00, type = ro;
	BANK_01:  load = BANK01, type = ro;
	STARTS:   load = BANK01, type = ro,  start = $FFF0;
	VECTORS:  load = BANK01, type = ro,  start = $FFFA;
	GRAPHIC:  load = CHAR00, type = ro;
}
