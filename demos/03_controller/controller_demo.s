;===============================================================================
.segment "HEADER"
;=====================
	.BYTE "NES", $1A	; iNES always stars with bytes  $4e,$45,$53,$1a
	.BYTE 1				; # of 16 KB PRG ROM Banks (this can vary by mapper)
	.BYTE 1				; # of 8 KB CHR ROM Banks (this can vary by mapper)
	;============================================================================================
	; iNES flag 6
	; 7654 3210
	; |||| ||||
	; |||| |||+- Mirroring: 0: horizontal (vertical arrangement) (CIRAM A10 = PPU A11)
	; |||| |||              1: vertical (horizontal arrangement) (CIRAM A10 = PPU A10)
	; |||| ||+-- 1: Cartridge contains battery-backed PRG RAM ($6000-7FFF) or other persistent memory
	; |||| |+--- 1: 512-byte trainer at $7000-$71FF (stored before PRG data)
	; |||| 
	; ||||+---- 1: Ignore mirroring control or above mirroring bit; instead provide four-screen VRAM
	; ++++----- Lower nybble of mapper number.  Note:  this can impact values used for PRG and CHR bytes
	;============================================================================================	
	.BYTE %00000000		; iNES flag 6

;===============================================================================
.segment "ZEROPAGE"
;======================
; LOGIC VALUES
.define TRUE		$01
.define FALSE		$00

; JOYPAD VALUES
.define A_BUTTON      %10000000
.define B_BUTTON      %01000000
.define SELECT_BUTTON %00100000
.define START_BUTTON  %00010000
.define UP_BUTTON     %00001000
.define DOWN_BUTTON   %00000100
.define LEFT_BUTTON   %00000010
.define RIGHT_BUTTON  %00000001

SOFT_2000:	.res 1
SOFT_2001:	.res 1
DRAW_FLAG:	.res 1
YSCROLL:	.res 1
XSCROLL:	.res 1
FADE:		.res 1
JOYRAW1:	.res 1
JOYRAW2:	.res 1
JOYPRESS1:	.res 1
JOYPRESS2:	.res 1
JOYHELD1:	.res 1
JOYHELD2:	.res 1
TEMP:		.res 3

;===============================================================================
.segment "SPRITE"
;=====================
.import __SPRITE_LOAD__
SQUARE:		.res 4
CIRCLE:		.res 4
TRIANGLE:	.res 4

;===============================================================================
.segment "PALETTE"
;=====================
.import __PALETTE_LOAD__

;===============================================================================
.segment "BANK_00"
;=====================
Reset:
	CLD				; Clear Decimal Mode (NES has no BCD)
	SEI				; Disable IRQs
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
	JSR fade_in		; Fade Screen to Full Color
game_loop:
	JSR alter_triangle
	JMP game_loop

alter_triangle:
@wait:
	LDA DRAW_FLAG		; Previous Updates Done?
	BNE @wait
@up:
	LDA JOYRAW1			; Up Button?
	AND #UP_BUTTON
	BEQ @down
	DEC TRIANGLE+0		; Move Sprite Y Up
	JMP @left
@down:
	LDA JOYRAW1			; Down Button?
	AND #DOWN_BUTTON
	BEQ @left
	INC TRIANGLE+0		; Move Sprite Y Down
@left:
	LDA JOYRAW1			; Left Button?
	AND #LEFT_BUTTON
	BEQ @right
	DEC TRIANGLE+3		; Move Sprite X Left
	JMP @a
@right:
	LDA JOYRAW1			; Right Button?
	AND #RIGHT_BUTTON
	BEQ @a
	INC TRIANGLE+3		; Move Sprite X Right
@a:
	LDA JOYPRESS1		; A Button Pressed
	AND #A_BUTTON
	BEQ @b
	LDA TRIANGLE+2		; Get Sprite Attributes
	TAX
	AND #%11111100		; Remove Sprite Palette
	STA TRIANGLE+2		; Store Sprite Attributes
	TXA
	AND #%00000011		; Get Sprite Palette
	CLC
	ADC #$01			; Next Palette
	CMP #%00000100		; Past Palette 3?
	BCC @store
	LDA #%00000000		; Wrap to Palette 0
@store:
	ORA TRIANGLE+2		; Set Palette in Sprite Attributes
	STA TRIANGLE+2		; Store Sprite Attributes
@b:
	LDA JOYPRESS1		; B Button Pressed
	AND #B_BUTTON
	BEQ @exit
	LDA TRIANGLE+2		; Get Sprite Attributes
	EOR #%10000000		; Flip Sprite Vertically
	STA TRIANGLE+2		; Store Attributes
@exit:
	LDA #TRUE			; Ready to Update
	STA DRAW_FLAG
	RTS

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
	LDY #$00				; Set Index to First Byte
	LDA #$F0				; Set Y Position to off-screen
:	STA __SPRITE_LOAD__,Y	; Store Y Position in OAM Buffer
	INY						; Set to next sprite
	INY
	INY
	INY
	BNE :-					; Last sprite?
	RTS

init_sound:
	LDA #%00001111			; Enable Sound Channels
	STA $4015
	LDA #%01000000			; Disable Frame IRQS
	STA $4017
	RTS

init_variables:
	LDA #$00
	STA YSCROLL				; Set Y Scroll
	STA XSCROLL				; Set X Scroll
	; Set Other Variables Here
	STA FADE				; Set Fade
	RTS

init_graphics:
	; Load Initial Screen Here
	JSR load_title_palette	; Load Title Palette
	JSR load_title_sprites	; Load Title Sprites
	RTS

;-----;
; NMI ;
;-----;

NMI:
	; Store Values
	PHA						; Push A
	TXA						; Push X
	PHA
	TYA						; Push Y
	PHA
	BIT $2002				; Acknowledge NMI and Reset $2005/$2006 Latch
	LDA DRAW_FLAG			; Check for Draw Screen Update
	CMP #TRUE
	BNE @done
	; Update Screen
	LDA #%00000000			; Forced Blank
	STA $2001
	JSR update_oam			; Update OAM
	JSR update_palette		; Update Palette RAM
	JSR update_vram			; Update VRAM
	JSR update_scroll		; Update Scroll
	LDA SOFT_2001			; Enable Screen
	STA $2001
@done:	LDA #FALSE			; Set Draw Screen to Done
	STA DRAW_FLAG
	JSR update_joypad		; Update Joypads
	; Return Values
	PLA						; Pull Y
	TAY
	PLA						; Pull X
	TAX
	PLA						; Pull A
IRQ:	RTI

;-----------------;
; NMI SUBROUTINES ;
;-----------------;

update_oam:
	LDA #$00				; Set to first byte in OAM
	STA $2003
	LDA #>__SPRITE_LOAD__	; Set to the OAM Buffer Memory Page
	STA $4014				; DMA OAM Buffer to OAM
	RTS


update_palette:
	LDA SOFT_2000			; Set VRAM Increment to Across
	AND #%11111011
	STA $2000
	LDA #>$3F00				; Set Palette RAM Address
	STA $2006
	LDA #<$3F00
	STA $2006
	LDX #$00				; Set Index to First Color
:	LDA __PALETTE_LOAD__,X	; Get Color
	AND #$F0				; Keep Color Hi Nibble (Brightness)
	ORA FADE				; Set Fade Timer Lo Nibble
	TAY						; Set as Index
	LDA __PALETTE_LOAD__,X	; Load Color
	AND #$0F				; Keep Color Lo Nibble
	ORA PALETTE_FADE,Y		; Set Color Hi Nibble
	STA $2007				; Store Color in Palette RAM
	INX						; Next Color
	CPX #$20				; Continue until Last Color
	BNE :-
	RTS

update_vram:
	; Update Background Code Here
	RTS

update_scroll:
	LDA SOFT_2000		; Set Name Table
	STA $2000
	LDA XSCROLL			; Set Vertical Scroll Offset
	STA $2005
	LDA YSCROLL			; Set Horizontal Scroll Offset
	STA $2005
	RTS

;-----------------;
; PALETTE SECTION ;
;-----------------;

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
	.BYTE $0F,$00,$00,$00, $0F,$00,$00,$00, $0F,$00,$00,$00, $0F,$00,$00,$00
	.BYTE $0F,$05,$15,$25, $0F,$0B,$1B,$2B, $0F,$01,$11,$21, $0F,$18,$28,$38

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
	JMP fade_in			; Check Next Fade Time
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

;----------------;
; SPRITE SECTION ;
;----------------;

load_title_sprites:
	LDX #<title_sprites	; Source Lo Byte
	LDY #>title_sprites	; Source Hi Byte
	LDA #.LOBYTE(title_sprites_end - title_sprites)	; Source Length
	JSR load_oam
	RTS

load_oam:
	STX TEMP+0				; Store Source Lo Byte
	STY TEMP+1				; Store Source Hi Byte
	STA TEMP+2				; Store Source Length
	; Clear OAM Buffer
	LDY #$00
	LDA #$F0				; Set Y Position to off-screen
:	STA __SPRITE_LOAD__,Y	; Store Y Position in OAM Buffer
	INY						; Set to next sprite
	INY
	INY
	INY
	BNE :-					; Last sprite?
	; Load Sprites into OAM Buffer
:	LDA (TEMP),Y			; Get Sprite Attribute
	STA __SPRITE_LOAD__,Y	; Store in OAM Buffer
	INY						; Next Sprite Attribute
	CPY TEMP+2				; Last Sprite Attribute?
	BNE :-
	RTS

title_sprites:
	.BYTE $3C,$01,%00000000,$20	; Square Sprite
	.BYTE $74,$02,%00000001,$7C	; Circle Sprite
	.BYTE $B0,$03,%00000010,$D8	; Triangle Sprite
title_sprites_end:

;----------------;
; JOYPAD SECTION ;
;----------------;

update_joypad:
	; Joypad Strobing
	LDA #$01
	STA $4016			; Set Strobe
	LDA #$00
	STA $4016			; Clear Strobe
	; Read Joypad 1
	LDX JOYRAW1			; Previous Joypad 1 Read
	LDY #$08			; Set to read 8 buttons
:	LDA $4016			; Get Joypad 1 Button
	LSR					; Set Button in Carry
	ROL JOYRAW1			; Set Button in Raw Data
	AND #%00000001		; Famicon Expansion Port 3 Button
	ORA JOYRAW1			; Set Famicon Button in Raw Data
	STA JOYRAW1			; Store Raw Data
	DEY					; Next Button
	BNE :-				; Last Button?
	; Pressed Button Check
	TXA					; Previous Joypad Read
	EOR JOYRAW1			; Find Button Changes
	AND JOYRAW1			; Find New Button Changes
	STA JOYPRESS1		; Store Pressed Buttons
	; Held Button Check
	TXA					; Previous Joypad Read
	AND JOYRAW1			; Find Same Buttons
	STA JOYHELD1		; Store Held Buttons
	; Read Joypad 2
	LDX JOYRAW2			; Previous Joypad 2 Read
	LDY #$08			; Set to read 8 buttons
:	LDA $4017			; Get Joypad 2 Button
	LSR					; Set Button in Carry
	ROL JOYRAW2			; Set Button in Raw Data
	AND #%00000001		; Famicon Expansion Port 4 Button
	ORA JOYRAW2			; Set Famicon Button in Raw Data
	STA JOYRAW2			; Store Raw Data
	DEY					; Next Button
	BNE :-				; Last Button?
	; Pressed Button Check
	TXA				; Previous Joypad Read
	EOR JOYRAW2			; Find Button Changes
	AND JOYRAW2			; Find New Button Changes
	STA JOYPRESS2		; Store Pressed Buttons
	; Held Button Check
	TXA					; Previous Joypad Read
	AND JOYRAW2			; Find Same Buttons
	STA JOYHELD2		; Store Held Buttons
	RTS

;===============================================================================
.segment "VECTORS"
;=====================
	.WORD NMI, Reset, IRQ

;===============================================================================
.segment "GRAPHIC"
;=====================
	.incbin "./resources/controller_demo.chr"
