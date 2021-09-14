# Sprite #0 Hit

The first object in the OAM is known as sprite #0 which has a special function.  The $2002 Register can show when this sprite has a rendered pixel at the same location as a rendered background pixel.  This allows us to perform various timed special effects but is mostly used to display status bars like at the top of the screen in Super Mario Bros.

We detect the sprite #0 hit by:

```nasm
@hit:
  BIT $2002      ; Wait Until Sprite #0 Not Hit
  BVS @hit
@nothit:
  BIT $2002      ; Wait Until Sprite #0 Hit
  BVC @nothit
  LDX #$14      ; Delay for End of Scanline
@delay:
  DEX
  BNE @delay
```

Note: the delay value will vary based on the location of the sprite and the special effect.

## Reset/Game Loop

In the Reset routine or Game Loop, we need to write the status bar to both name tables.

```nasm
load_status_bar:
  LDA #$02
  STA TEMP+2
  LDA SOFT_2000
  AND #%11111011
  STA $2000
  LDA #>$2000
@address:
  STA $2006
  LDA #<$2000
  STA $2006
  LDX #.LOBYTE(status_bar_end - status_bar)
  LDY #$00
@loop:
  LDA status_bar,Y
  STA $2007
  INY
  DEX
  BNE @loop
  DEC TEMP+2
  BEQ @exit
  LDA #>$2400
  JMP @address
@exit:
  RTS

status_bar:
.BYTE $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
.BYTE $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
.BYTE $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
.BYTE $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
.BYTE $24,$24,$24,$16,$0A,$1B,$12,$18,$24,$24,$24,$24,$24,$24,$24,$24
.BYTE $24,$24,$20,$18,$1B,$15,$0D,$24,$24,$1D,$12,$16,$0E,$24,$24,$24
.BYTE $24,$24,$24,$00,$00,$00,$00,$00,$00,$24,$24,$2E,$29,$00,$00,$24
.BYTE $24,$24,$24,$01,$28,$01,$24,$24,$24,$24,$02,$03,$06,$24,$24,$24
status_bar_end:
```

## NMI

In the NMI, we need to set the name table with the status bar with no scrolling and we need to update the scroll once rendering is on after the sprite #0 hit.

```nasm
  ; Store Values
  PHA        ; Push A
  TXA        ; Push X
  PHA
  TYA        ; Push Y
  PHA
  BIT $2002      ; Acknowledge NMI and Reset $2005/$2006 Latch
  LDA DRAW_FLAG    ; Check for Draw Screen Update
  CMP #TRUE
  BNE @done
  ; Update Screen
  LDA #%00000000    ; Forced Blank
  STA $2001
  JSR update_oam    ; Update OAM
  JSR update_palette  ; Update Palette RAM
  JSR update_vram    ; Update VRAM
  JSR update_status    ; Update Status Bar
  LDA SOFT_2001    ; Enable Screen
  STA $2001
  JSR update_scroll    ; Update Scroll
@done:  
LDA #FALSE      ; Set Draw Screen to Done
  STA DRAW_FLAG
  JSR update_joypad    ; Update Joypads
  ; Return Values
  PLA        ; Pull Y
  TAY
  PLA        ; Pull X
  TAX
  PLA        ; Pull A
  RTI

update_status:
  LDA SOFT_2000    ; Get $2000 Settings
  AND #%11111100    ; Set to Name Table 0
  STA $2000      ; Store $2000 Settings
  LDA #$00      ; No X Scroll
  STA $2005
  LDA #$00      ; NO Y Scroll
  STA $2005
  RTS

update_scroll:
@hit:
  BIT $2002      ; Wait Until Sprite #0 Not Hit
  BVS @hit
@nothit:
  BIT $2002      ; Wait Until Sprite #0 Hit
  BVC @nothit
  LDX #$14      ; Delay for End of Scanline
@delay:
  DEX
  BNE @delay
  LDA SOFT_2000    ; Get $2000 Settings
  AND #%11111100    ; Remove Name Table
  STA SOFT_2000
  LDA XSCROLL+1    ; Get Name Table
  AND #%00000001
  ORA SOFT_2000    ; Add $2000 Settings
  STA SOFT_2000    ; Store $2000 Settings
  STA $2000
  LDA XSCROLL+0    ; Set Vertical Scroll Offset
  STA $2005
  LDA YSCROLL      ; Set Horizontal Scroll Offset
  STA $2005
  RTS
```

## Subroutine Changes

In our code to load and draw the columns, we need to start drawing under the status bar to prevent drawing over it.

```nasm
load_name_table:
  LDA #$21      ; Set Columns to Draw
  STA DRAW_WIDTH
@column:
  LDX XSCROLL+0    ; X Lo
  LDY XSCROLL+1    ; X Hi
  JSR get_column    ; Get Name Table and Source Addresses
  LDA #$1A      ; Number of Tiles in Column
  STA DRAW_HEIGHT
  JSR draw_column    ; Draw Column to VRAM
  LDX XSCROLL+0    ; X Lo
  LDY XSCROLL+1    ; X Hi
  JSR get_attribute    ; Get Attribute Table and Source Addresses
  JSR draw_attribute  ; Draw Attribute to VRAM
  LDA XSCROLL+0    ; Next Column
  CLC
  ADC #<$0008
  STA XSCROLL+0
  LDA XSCROLL+1
  ADC #>$0008
  STA XSCROLL+1
  DEC DRAW_WIDTH    ; Last Column?
  BNE @column
  LDA XSCROLL+0    ; Set to Original Location
  SEC
  SBC #<$0108
  STA XSCROLL+0
  LDA XSCROLL+1
  SBC #>$0108
  STA XSCROLL+1
  RTS

get_column:
  ; Get Name Table Address
  TXA        ; X Lo / 8 = Name Table Address Lo
  LSR
  LSR
  LSR
  STA VRAM_ADDRESS+0
  TYA        ; X Hi
  AND #%00000001    ; Keep Name Table Side
  ASL        ; Name Table Side * 4 + $20 = Name Table Address Hi
  ASL
  ADC #>$2000
  STA VRAM_ADDRESS+1
  ; Skip Status Bar
  LDA VRAM_ADDRESS+0
  CLC
  ADC #<$0080
  STA VRAM_ADDRESS+0
  LDA VRAM_ADDRESS+1
  ADC #>$0080
  STA VRAM_ADDRESS+1
  ; Get Source Index
  LDA XSCROLL+0    ; X / 8 = Column
  STA SOURCE+0
  LDA XSCROLL+1
  STA SOURCE+1
  LSR SOURCE+1
  ROR SOURCE+0
  LSR SOURCE+1
  ROR SOURCE+0
  LSR SOURCE+1
  ROR SOURCE+0
  ASL SOURCE+0    ; (Column * 32) - (Column * 6) = Source Index
  ROL SOURCE+1
  LDA SOURCE+0
  STA TEMP+0
  LDA SOURCE+1
  STA TEMP+1
  ASL SOURCE+0
  ROL SOURCE+1
  ASL SOURCE+0
  ROL SOURCE+1
  ASL SOURCE+0
  ROL SOURCE+1
  ASL SOURCE+0
  ROL SOURCE+1
  LDX #$03
@loop:
  LDA SOURCE+0
  SEC
  SBC TEMP+0
  STA SOURCE+0
  LDA SOURCE+1
  SBC TEMP+1
  STA SOURCE+1
  DEX
  BNE @loop
  ; Get Source Address
  LDA SOURCE+0    ; Source Index + Source = Source Address
  CLC
  ADC #<title_name_table
  STA SOURCE+0
  LDA SOURCE+1
  ADC #>title_name_table
  STA SOURCE+1
  RTS

buffer_column:
  LDX VRAM_ADDRESS+0  ; Set VRAM Address Lo
  LDA VRAM_ADDRESS+1  ; Set VRAM Address Hi
  CLC
  ADC #%10000000    ; Add VRAM Increment Down
  TAY
  LDA #$1A      ; Set Number of Rows in Column
  JSR buffer_vram
  RTS
```
