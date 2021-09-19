# Skeleton of Demo Codes

## Reset Routine

The reset routine is set by the Reset Vector and is run at power on or at reset.  We need to clear the settings, wait for the PPU to warm-up (wait about 29658 cycles before we can write to VRAM), clear any RAM, and create the initial screen before entering the main game loop.

```nasm
Reset:
CLD       ; Clear Decimal Mode (NES has no BCD)
SEI       ; Disable IRQs
LDX #$FF      ; Reset the Stack Pointer
TXS
; Clear the Work RAM ($0000-$07FF)
  LDA #$00
  STA $00
  STA $01
  TAY
  LDX #$08
:  STA ($00),Y
  INY
  BNE :-
  INC $01
  DEX
  BNE :-
  STA $01
  ; Disable Rendering
  LDA #%00000000
  STA $2000     ; Disable NMIs
  STA $2001     ; Forced Blank
  ; Wait for PPU Warm-Up
  LDX #$02
:  LDA $2002
  BPL :-
:  LDA $2002
  BMI :-
  DEX
  BNE :--
; Initiate APU and PPU
JSR clear_vram    ; Clear Name and Attribute Tables
JSR clear_oam    ; Clear OAM Buffer
JSR init_sound    ; Initialize Sound
JSR init_variables  ; Initialize Variables
JSR init_graphics    ; Initialize Screen
; Set PPU Control Registers.
LDA #%10010000    ; NMI, BG $1000, Objects $0000, Name Base $2000
STA $2000
STA SOFT_2000
LDA #%00011110    ; Display BG and Objects
STA SOFT_2001
CLI       ; Enable IRQs
game_loop:
JMP game_loop    ; Game Loop Here
clear_vram: ; EXPLAINED IN FUTURE
  ; Set VRAM Increment to Across
  LDA SOFT_2000
  AND #%11111011
  STA $2000
  ; Set VRAM Address to $2400
  LDA #>$2400
  STA $2006
  LDA #<$2400
  STA $2006
  ; Clear the Name and Attribute Tables at $2400 and $2800
  LDX #>$0800
  LDY #<$0800
  LDA #$00
:  STA $2007
  INY
  BNE :-
  DEX
  BNE :-
  RTS

clear_oam: ; EXPLAINED IN FUTURE
  ; Clear OAM Buffer
  LDY #$00
  LDA #$F0
:  STA SPRITE,Y
  INY
  INY
  INY
  INY
  BNE :-
  RTS

init_sound: ; EXPLAINED IN FUTURE
  LDA #%00001111    ; Enable Sound Channels
  STA $4015
  LDA #%01000000    ; Disable Frame IRQs
  STA $4017
  RTS

init_variables: ; EXPLAINED IN FUTURE
  LDA #$00
  STA YSCROLL     ; Set Y Scroll
  STA XSCROLL     ; Set X Scroll
  ; Set Other Variables Here
  RTS

init_graphics:
  ; Load Initial Screen Here
  RTS
```

## NMI Routine

The NMI routine is set by the NMI Vector and is run when NMIs are enabled at the beginning of each vertical blank.  Vertical Blank is the time just before rendering the screen when the PPU’s VRAM may be accessed.  We want to update the PPU and perform all tasks needed each frame here.

```nasm
NMI:
  ; Store Values
  PHA       ; Push A
  TXA       ; Push X
  PHA
  TYA       ; Push Y
  PHA
  BIT $2002     ; Acknowledge NMI and Reset $2005/$2006 Latch
  ; Update Screen
  LDA #%00000000    ; Forced Blank
  STA $2001
  JSR update_oam    ; Update OAM
  JSR update_palette  ; Update Palette RAM
  JSR update_vram    ; Update VRAM
  JSR update_scroll    ; Update Scroll
  ; Updates to Screen Done
  LDA SOFT_2001    ; Enable Screen
  STA $2001
  ; Return Values
  PLA       ; Pull Y
  TAY
  PLA       ; Pull X
  TAX
  PLA       ; Pull A
RTI

update_oam: ; EXPLAINED IN FUTURE
  LDA #$00
  STA $2003
LDA #>SPRITE    ; Store OAM Buffer into OAM
STA $4014
RTS

update_palette:
  ; Update Palette Code Here
  RTS

update_vram:
  ; Update VRAM Code Here
  RTS

update_scroll: ; EXPLAINED IN FUTURE
  LDA SOFT_2000    ; Set Name Table
  STA $2000
  LDA XSCROLL     ; Set Vertical Scroll Offset
  STA $2005
  LDA YSCROLL     ; Set Horizontal Scroll Offset
  STA $2005
  RTS
```

## IRQ Routine

The IRQ routine is set by the IRQ/BRK Vector and handles interrupt requests.  Generally IRQs are used to create screen effects.

```nasm
IRQ:  RTI
```

## Vectors

The Vectors are the pointers to the NMI, Reset, and IRQ routines.

```nasm
.segment "VECTORS"
  .WORD NMI, Reset, IRQ
```
