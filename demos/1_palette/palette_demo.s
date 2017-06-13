;===============================================================================
.segment "HEADER"
;=====================
	.BYTE "NES", $1A	; NES^Z
	.BYTE 1			; #16 KB PRG ROM Banks
	.BYTE 1			; #8 KB CHR ROM Banks
	.BYTE %00000000		; ROM Control Byte #1
	.BYTE %00000000		; ROM Control Byte #2
	.BYTE 0			; #8 KB PRG RAM Banks
	.BYTE %00000000		; TV System

;===============================================================================
.segment "ZEROPAGE"
;======================
; LOGIC VALUES
.define TRUE	$01
.define FALSE	$00

.ZEROPAGE
SOFT_2000:	.res 1
SOFT_2001:	.res 1
DRAW_FLAG:	.res 1
YSCROLL:	.res 1
XSCROLL:	.res 1
FADE:		.res 1
TEMP:		.res 2

;===============================================================================
.segment "SPRITE"
;=====================
.import __SPRITE_LOAD__

;===============================================================================
.segment "PALETTE"
;=====================
.import __PALETTE_LOAD__

;===============================================================================
.segment "BUFFER"
;=====================
.import __BUFFER_LOAD__

;===============================================================================
.segment "BANK_00"
;=====================
Reset:
	CLD			; Clear Decimal Mode (NES has no BCD)
	SEI			; Disable IRQs
	LDX #$FF 		; Reset the Stack Pointer
	TXS
	; Clear the Work RAM ($0000-$07FF)
	LDA #$00
	STA $00
	STA $01
	TAY
	LDX #$08
:	STA ($00),Y
	INY
	BNE :-
	INC $01
	DEX
	BNE :-
	STA $01
	; Disable Rendering
	LDA #%00000000
	STA $2000		; Disable NMIs
	STA $2001		; Forced Blank
	; Wait for PPU Warm-Up
	LDX #$02
:	LDA $2002
	BPL :-
:	LDA $2002
	BMI :-
	DEX
	BNE :--
	; Initiate APU and PPU
	JSR clear_vram		; Clear Name and Attribute Tables
	JSR clear_oam		; Clear OAM Buffer
	JSR init_sound		; Initialize Sound
	JSR init_variables	; Initialize Variables
	JSR init_graphics	; Initialize Screen
	; Set PPU Control Registers.
	LDA #%10010000		; NMI, BG $1000, Objects $0000, Name Base $2000
	STA $2000
	STA SOFT_2000
	LDA #%00011110		; Display BG and Objects
	STA SOFT_2001
	CLI			; Enable IRQs
	LDA #TRUE		; Ready to Update Initial Screen
	STA DRAW_FLAG
:	LDA DRAW_FLAG		; Updated?
	BNE :-
game_loop:
	JSR fade_in
	JSR fade_out
	JMP game_loop

;------------------------;
; INITIALIZATION SECTION ;
;------------------------;

clear_vram:
	; Set VRAM Increment to Across
	LDA SOFT_2000
	AND #%11111011
	STA $2000
	; Set PPU Address to $2400
	LDA #>$2400
	STA $2006
	LDA #<$2400
	STA $2006
	; Clear the Name and Attribute Tables at $2400 and $2800
	LDX #>$0800
	LDY #<$0800
	LDA #$00
:	STA $2007
	INY
	BNE :-
	DEX
	BNE :-
	RTS

clear_oam:
	; Clear OAM Buffer
	LDY #$00
	LDA #$F0
:	STA __SPRITE_LOAD__,Y
	INY
	INY
	INY
	INY
	BNE :-
	RTS

init_sound:
	LDA #%00001111		; Enable Sound Channels
	STA $4015
	LDA #%01000000		; Disable Frame IRQS
	STA $4017
	RTS

init_variables:
	LDA #$00
	STA YSCROLL		; Set Y Scroll
	STA XSCROLL		; Set X Scroll
	; Set Other Variables Here
	STA FADE		; Set Fade
	RTS

init_graphics:
	; Load Initial Screen Here
	JSR load_title_palette	; Load Title Palette
	RTS

NMI:
	; Store Values
	PHA			; Push A
	TXA			; Push X
	PHA
	TYA			; Push Y
	PHA
	BIT $2002		; Acknowledge NMI and Reset $2005/$2006 Latch
	LDA DRAW_FLAG		; Check for Draw Screen Update
	CMP #TRUE
	BNE @done
	; Update Screen
	LDA #%00000000		; Forced Blank
	STA $2001
	JSR update_oam		; Update OAM
	JSR update_palette	; Update Palette RAM
	JSR update_vram		; Update VRAM
	JSR update_scroll	; Update Scroll
	LDA SOFT_2001		; Enable Screen
	STA $2001
@done:	LDA #FALSE		; Set Draw Screen to Done
	STA DRAW_FLAG
	; Return Values
	PLA			; Pull Y
	TAY
	PLA			; Pull X
	TAX
	PLA			; Pull A
IRQ:	RTI

;-----------------;
; NMI SUBROUTINES ;
;-----------------;

update_oam:
	LDA #$00
	STA $2003
	LDA #>__SPRITE_LOAD__	; Store OAM Buffer into OAM
	STA $4014
	RTS

update_palette:
	LDA SOFT_2000		; Set VRAM Increment to Across
	AND #%11111011
	STA $2000
	LDA #>$3F00		; Set Palette RAM Address
	STA $2006
	LDA #<$3F00
	STA $2006
	LDX #$00		; Set Index to First Color
:	LDA __PALETTE_LOAD__,X	; Get Color
	AND #$F0		; Keep Color Hi Nibble (Brightness)
	ORA FADE		; Set Fade Timer Lo Nibble
	TAY			; Set as Index
	LDA __PALETTE_LOAD__,X	; Load Color
	AND #$0F		; Keep Color Lo Nibble
	ORA PALETTE_FADE,Y	; Set Color Hi Nibble
	STA $2007		; Store Color in Palette RAM
	INX			; Next Color
	CPX #$20		; Continue until Last Color
	BNE :-
	RTS

update_vram:
	; Update Background Code Here
	RTS

update_scroll:
	LDA SOFT_2000		; Set Name Table
	STA $2000
	LDA XSCROLL		; Set Vertical Scroll Offset
	STA $2005
	LDA YSCROLL		; Set Horizontal Scroll Offset
	STA $2005
	RTS

;------------------
; PALETTE SECTION ;
;------------------

load_palette:
	STX TEMP+0
	STY TEMP+1
	; Load palette into Buffer
	LDY #$00
:	LDA (TEMP),Y
	STA __PALETTE_LOAD__,Y
	INY
	CPY #$20
	BNE :-
	RTS

load_title_palette:
	; Load palette Location
	LDX #<title_palette
	LDY #>title_palette
	JSR load_palette
	RTS

title_palette:
	.BYTE $32,$01,$11,$21, $32,$05,$15,$25, $32,$11,$21,$31, $32,$15,$25,$35
	.BYTE $32,$08,$18,$28, $32,$0B,$1B,$2B, $32,$18,$28,$38, $32,$1B,$2B,$3B

fade_in:
	LDA FADE		; Current Fade Timer
	CMP #$0F		; End of Fade In?
	BCS @done
	INC FADE		; Increase Fade Timer
	LDA #TRUE		; Ready to Update
	STA DRAW_FLAG
@wait:
	LDA DRAW_FLAG		; Updated?
	BNE @wait
	JMP fade_in		; Check Next Fade Time
@done:
	RTS

fade_out:
	LDA FADE		; Current Fade Timer
	BEQ @done		; End of Fade Out?
	DEC FADE		; Decrease Fade Timer
	LDA #TRUE		; Ready to Update
	STA DRAW_FLAG
@wait:
	LDA DRAW_FLAG		; Updated?
	BNE @wait
	JMP fade_out		; Check Next Fade Timer
@done:
	RTS

PALETTE_FADE:
	.BYTE $0F, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00	; $00-$0F Colors
	.BYTE $0F, $00, $00, $00, $00, $00, $00, $00, $10, $10, $10, $10, $10, $10, $10, $10	; $10-$1F Colors
	.BYTE $0F, $00, $00, $00, $00, $00, $10, $10, $10, $10, $10, $10, $20, $20, $20, $20	; $20-$2F Colors
	.BYTE $0F, $00, $00, $00, $10, $10, $10, $10, $20, $20, $20, $20, $30, $30, $30, $30	; $30-$3F Colors

;===============================================================================
.segment "BANK_01"
;=====================

;===============================================================================
.segment "VECTORS"
;=====================
	.WORD NMI, Reset, IRQ

;===============================================================================
.segment "GRAPHIC"
;=====================
