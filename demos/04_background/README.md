# Background

- The background is 32x30 tiles (256x240 pixels) with the NTSC not displaying the top and bottom rows (256x224 pixels).  The background is stored in name tables and colored using attribute tables.
- The $2000 Register set the tile pattern to be used for the 8x8 tiles and the name table to be displayed.
- The $2001 Register sets whether the background is to be displayed on screen and whether to display the left column of the screen.
- The $2006 Register sets the address in VRAM to write to and the $2007 Register writes the data to the VRAM.
- Example:

```nasm
LDA #$20        ; VRAM Address Hi Byte
STA $2006       ; Store VRAM Address Hi Byte
LDA #$00        ; VRAM Address Lo Byte
STA $2006       ; Store VRAM Address Lo Byte
LDA #$01        ; Data
STA $2007       ; Store #$01 into VRAM Address $2000
```

## Name Tables

A name table is a tile map in VRAM with each byte representing a tile number from the tile pattern.  Each row is 32 tiles wide and each column is 30 tiles long.

The NES has 4 name tables but only enough internal memory to be able to use 2 name tables.  The NES cartridge is setup to have either vertical mirroring or horizontal mirroring (note: mappers can allow a game to change mirroring or add RAM allowing all 4 name tables).  Vertical mirroring makes name table 0 ($2000-$23BF) and name table 2 ($2800-$2BBF) the same and name table 1 ($2400-$27BF) and name table 3 ($2C00-$2FBF) the same.  Horizontal mirroring makes name table 0 ($2000-$23BF) and name table 1 ($2400-$27BF) the same and name table 2 ($2800-$2BBF) and name table 3 ($2C00-$2FBF) the same.  A classic game that uses vertical mirroring is Super Mario Bros. and a classic game that uses horizontal mirroring is Ice Climber.

```text
+----------------+----------------+
|                |                |
|                |                |
|  NAME TABLE 0  |  NAME TABLE 1  |
|                |                |
|  $2000-$23BF   |  $2400-$27BF   |
|                |                |
|                |                |
+----------------+----------------+
|                |                |
|                |                |
|  NAME TABLE 2  |  NAME TABLE 3  |
|                |                |
|  $2800-$2BBF   |  $2C00-$2FBF   |
|                |                |
|                |                |
+----------------+----------------+
```


## Attribute Tables

An attribute table is a color table for the tile map in VRAM with each byte coloring a 4x4 tile square (32x32 pixels).

Each attribute table byte is %76543210
                              ||||||||
                              ||||||++- Top Left 2x2 Tiles
                              ||||++--- Top Right 2x2 Tiles
                              ||++----- Bottom Left 2x2 Tiles
                              ++------- Bottom Right 2x2 Tiles

Each 2x2 sets the bits where 00 = Palette 0, 01 = Palette 1, 10 = Palette 2, and 11 = Palette 3.

Attribute Table 0 is $23C0-$23FF
Attribute Table 1 is $27C0-$27FF
Attribute Table 2 is $2BC0-$2BFF
Attribute Table 3 is $2FC0-$2FFF

Here is an example of the screen set to a grid for the attribute table.

At the bottom of the screen we see the palettes and examples of the 2x2 tile coloring.

## Reset

In the reset routine we need to clear the name and attribute tables and write the background for the initial screen during forced blank.

```nasm
clear_vram:
	LDA SOFT_2000      ; Get $2000 Register Settings
	AND #%11111011      ; Set VRAM Increment to Across
	STA $2000	      ; Store $2000 Register Settings
	LDA #>$2400	      ; VRAM Address Hi Byte
	STA $2006	      ; Store VRAM Address Hi Byte
	LDA #<$2400	      ; VRAM Address Lo Byte
	STA $2006	      ; Store VRAM Address Lo Byte
      ; Clear the Name and Attribute Tables at $2400 and $2800
      ; Mirroring will Clear the Tables at $2000 and $2C00
	LDX #>$0800	      ; Set Index Length Hi Byte
	LDY #<$0800	      ; Set Index Length Lo Byte
	LDA #$00	      ; Clear Data
:	STA $2007	      ; Store Data in VRAM
	INY		      ; Next Lo Byte
	BNE :-	      ; Increase Hi Byte?
	DEX		      ; Next Hi Byte
	BNE :-	      ; Done?
	RTS
```

Reset/Forced Blank:

In forced blank, we can write directly to VRAM for as long as we need.

```nasm
load_title_vram:
	LDX #<title_vram	      ; Source Lo Byte
	LDY #>title_vram	      ; Source Hi Byte
	JSR load_vram
	RTS

load_vram:
	STX TEMP+0		      ; Store Source Lo
	STY TEMP+1		      ; Store Source Hi
	LDY #$00		      ; Set to First Byte of Source Address
@next:
	INY			      ; Set to VRAM Address Hi Byte
	LDA (TEMP),Y	      ; Get VRAM Address Hi Byte
	AND #%11000000	      ; Get VRAM Increment Flag
	STA VRAM_INCREMENT      ; Store VRAM Increment Flag
	LDA SOFT_2000	      ; Get $2000 Settings
	AND #%11111011	      ; Set VRAM Increment to Across
	BIT VRAM_INCREMENT      ; Check VRAM Increment Flag
	BPL @inc
	ORA #%00000100	      ; Set VRAM Increment to Down
@inc:
	STA $2000		      ; Store VRAM Increment
	LDA (TEMP),Y	      ; Get VRAM Address Hi Byte
	AND #%00111111	      ; Remove VRAM Increment Flag
	STA $2006		      ; Store VRAM Address Hi Byte
	DEY
	LDA (TEMP),Y	      ; Get VRAM Address Lo Byte
	STA $2006		      ; Store VRAM Address Lo Byte
	INY			      ; Set Y to Source Data
	INY
@store:
	LDA (TEMP),Y	      ; Get Source Data
	CMP #$FE		      ; Check for Control Bytes
	BCS @end
	STA $2007		      ; Store Byte into VRAM
	INY			      ; Next Byte
	BNE @store		      ; Wrap?
	INC TEMP+1		      ; Increase Source Hi Byte
	JMP @store
@end:
	CMP #$FF		      ; Check for End Control Byte
	BNE @next
	RTS
```

## Game Loop

In the Game Loop, we want to calculate the name and attribute changes and store them into a buffer.  The NMI is too short to write a full name table so buffering is a must and entire screens need to be done in forced blank (this is why NES games quickly go black between full screen changes).

Buffer Format:

```text
Byte 1:  %76543210
          ||||||||
          ||++++++- Data Length
          |+------- Repeat (0 = No Repeat, 1 = Repeat)
          +-------- VRAM Increment (0 = Across, 1 = Down)
Byte 2:  VRAM Address Lo Byte
Byte 3:  VRAM Address Hi Byte
Byte 4+: Data
```

```nasm
buffer_vram:
	STX TEMP+0		      ; Store VRAM Address Lo
	STY TEMP+1		      ; Store VRAM Address Hi
	STA TEMP+2  	      ; Store Source Length
	LDX BUFFER_LENGTH	      ; Get Current Buffer Length
	STX BUFFER_END	      ; Store X as Buffer End
	LDA TEMP+0		      ; Get VRAM Address Lo Byte
	STA BUFFER+1,X	      ; Store VRAM Address Lo Byte in Buffer
	LDA TEMP+1		      ; Get VRAM Address Hi Byte
	AND #%11000000	      ; Get VRAM Increment and Repeat Flag
	STA VRAM_INCREMENT      ; Store VRAM Increment and Repeat Flag
	LDA TEMP+1		      ; Get VRAM Address Hi Byte
	AND #%00111111	      ; Remove VRAM Increment and Repeat Flag
	STA BUFFER+2,X	      ; Store VRAM Address Hi Byte in Buffer
	LDY #$00		      ; Set to First Byte of Source Address
	BIT VRAM_INCREMENT      ; Check for Repeat Flag
	BVS @repeat
@next:
	LDA (SOURCE),Y	      ; Get Source Data
	CPY TEMP+2		      ; Last Byte?
	BEQ @length
	STA BUFFER+3,X	      ; Store Byte into Buffer
	INY			      ; Next Byte
	INX			      ; Next Byte in Buffer
	JMP @next
@length:
	TXA			      ; Get Length
	SEC
	SBC BUFFER_END	      ; Subtract Length from Buffer End
	ORA VRAM_INCREMENT      ; Add VRAM Increment and Repeat Flag
	LDX BUFFER_END	      ; Set Index to Original End
	STA BUFFER+0,X	      ; Store Bytes Used into Buffer
	AND #%00111111	      ; Remove VRAM Increment and Repeat Flag
	JMP @end
@repeat:
	LDA (SOURCE),Y	      ; Get Source Data
	STA BUFFER+3,X	      ; Store Byte into Buffer
	LDA TEMP+2		      ; Set Data Length
	ORA VRAM_INCREMENT      ; Add VRAM Increment and Repeat Flag
	LDX BUFFER_END	      ; Set Index to Original End
	STA BUFFER+0,X	      ; Store Data Length into Buffer
	LDA #$01		      ; Set to Bytes Used
@end:
	CLC
	ADC BUFFER_END	      ; Add Bytes Used to Buffer End
	ADC #$03		      ; Add VRAM Address and Length Bytes
	STA BUFFER_LENGTH	      ; Store New Buffer Length
	RTS
```

## NMI

In the NMI, we want to update the Name and Attribute Tables with our buffer.

```nasm
update_vram:
	LDA #$00		      ; Set to Clear
	LDX BUFFER_LENGTH	      ; Get Buffer Length
	STA BUFFER+0,X	      ; Store 0 at End
	STA BUFFER_LENGTH	      ; Clear Buffer Length
	TAY			      ; Set to First Byte in Buffer
@next:
	LDA BUFFER+0,Y	      ; Get Data Length
	BEQ @end		      ; End?
	STA VRAM_INCREMENT      ; Get VRAM Increment Flag and Repeat Flag
	AND #%00111111	      ; Remove VRAM Increment Flag and Repeat Flag
	TAX			      ; Set X to Data Length
	LDA SOFT_2000	      ; Get $2000 Settings
	AND #%11111011	      ; Set VRAM Increment to Across
	BIT VRAM_INCREMENT      ; Check VRAM Increment Flag
	BPL @inc
	ORA #%00000100	      ; Set VRAM Increment to Down
@inc:
	STA $2000		      ; Store VRAM Increment
	LDA BUFFER+2,Y	      ; Get VRAM Address Hi Byte
	STA $2006		      ; Store VRAM Address Hi Byte
	LDA BUFFER+1,Y	      ; Get VRAM Address Lo Byte
	STA $2006		      ; Store VRAM Address Lo Byte
	INY			      ; Set Y + 3 to First Data Byte
	INY
; Store Data in VRAM (V clear = X Data, V set = repeat Data X times)
	BVC @loop		      ; Check Repeat Flag
	INY
@loop:
	BVS @store		      ; Repeat?
	INY
@store:
	LDA BUFFER+0,Y	      ; Get Data
	STA $2007		      ; Store Data in VRAM
	DEX			      ; Next Byte
	BNE @loop
	INY			      ; Check Next in Buffer
	JMP @next
@end:
	RTS
```