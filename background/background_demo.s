;===============================================================================
.segment "HEADER"
;=====================
.segment "HEADER"
	.BYTE "NES", $1A	; NES^Z
	.BYTE 1				; #16 KB PRG ROM Banks
	.BYTE 1				; #8 KB CHR ROM Banks
	.BYTE %00000000		; ROM Control Byte #1
	.BYTE %00000000		; ROM Control Byte #2
	.BYTE 0				; #8 KB PRG RAM Banks
	.BYTE %00000000		; TV System

;===============================================================================
.segment "ZEROPAGE"
;======================
; LOGIC VALUES
.define TRUE	$01
.define FALSE	$00

; JOYPAD VALUES
.define A_BUTTON      %10000000
.define B_BUTTON      %01000000
.define SELECT_BUTTON %00100000
.define START_BUTTON  %00010000
.define UP_BUTTON     %00001000
.define DOWN_BUTTON   %00000100
.define LEFT_BUTTON   %00000010
.define RIGHT_BUTTON  %00000001

.ZEROPAGE
SOFT_2000:	.res 1
SOFT_2001:	.res 1
VRAM_INCREMENT:	.res 1
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
BUFFER_LENGTH:	.res 1
BUFFER_END:	.res 1
SOURCE:		.res 2
TEMP:		.res 3

;===============================================================================
.segment "SPRITE"
;=====================
.import __SPRITE_LOAD__
MARIO:		.res 16

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
	JSR fade_in		; Fade Screen to Full Color
game_loop:
	JSR write_message
	JMP game_loop

write_message:
	LDA JOYPRESS1
	AND #A_BUTTON
	BEQ @b
@waita:
	LDA DRAW_FLAG
	BNE @waita
	LDX #<$21C9
	LDY #>$21C9
	LDA #<message
	STA SOURCE+0
	LDA #>message
	STA SOURCE+1
	LDA #.LOBYTE(message_end - message)
	JSR buffer_vram
	LDX #<$23DA
	LDY #>$23DA
	LDA #<message_color
	STA SOURCE+0
	LDA #>message_color
	STA SOURCE+1
	LDA #.LOBYTE(message_color_end - message_color)
	JSR buffer_vram
	LDA #TRUE
	STA DRAW_FLAG
	JMP @exit
@b:	
	LDA JOYPRESS1
	AND #B_BUTTON
	BEQ @exit
@waitb:
	LDA DRAW_FLAG
	BNE @waitb
	LDX #<$21C9
	LDY #>$21C9  + %01000000
	LDA #<restore
	STA SOURCE+0
	LDA #>restore
	STA SOURCE+1
	LDA #$0D
	JSR buffer_vram
	LDX #<$23DA
	LDY #>$23DA  + %01000000
	LDA #<restore_color
	STA SOURCE+0
	LDA #>restore_color
	STA SOURCE+1
	LDA #$04
	JSR buffer_vram
	LDA #TRUE
	STA DRAW_FLAG
@exit:
	RTS

;------------------------;
; INITIALIZATION SECTION ;
;------------------------;

clear_vram:
	LDA SOFT_2000		; Get $2000 Register Settings
	AND #%11111011		; Set VRAM Increment to Across
	STA $2000		; Store $2000 Register Settings
	LDA #>$2400		; VRAM Address Hi Byte
	STA $2006		; Store VRAM Address Hi Byte
	LDA #<$2400		; VRAM Address Lo Byte
	STA $2006		; Store VRAM Address Lo Byte
	; Clear the Name and Attribute Tables at $2400 and $2800
	; Mirroring will Clear the Tables at $2000 and $2C00
	LDX #>$0800		; Set Index Length Hi Byte
	LDY #<$0800		; Set Index Length Lo Byte
	LDA #$00		; Clear Data
:	STA $2007		; Store Data in VRAM
	INY			; Next Lo Byte
	BNE :-			; Increase Hi Byte?
	DEX			; Next Hi Byte
	BNE :-			; Done?
	RTS

clear_oam:
	; Clear OAM Buffer
	LDY #$00		; Set Index to First Byte
	LDA #$F0		; Set Y Position to off-screen
:	STA __SPRITE_LOAD__,Y	; Store Y Position in OAM Buffer
	INY			; Set to next sprite
	INY
	INY
	INY
	BNE :-			; Last sprite?
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
	JSR load_title_sprites	; Load Title Sprites
	JSR load_title_vram	; Load Title Background
	RTS

;-----;
; NMI ;
;-----;

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
	JSR update_joypad	; Update Joypads
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
	LDA #$00		; Set to first byte in OAM
	STA $2003
	LDA #>__SPRITE_LOAD__	; Set to the OAM Buffer Memory Page
	STA $4014		; DMA OAM Buffer to OAM
	RTS

update_palette:
	LDA FADE		; Get Fade
	CMP #$0F		; Full Color?
	BNE @exit
	LDA SOFT_2000		; Set VRAM Increment to Across
	AND #%11111011
	STA $2000
	LDA #>$3F00		; Set Palette RAM Address
	STA $2006
	LDA #<$3F00
	STA $2006
	LDX #$00		; Set Index to First Color
@loop:
	LDA __PALETTE_LOAD__,X	; Load Color
	STA $2007		; Store Color in Palette RAM
	INX			; Next Color
	CPX #$20		; Continue until Last Color
	BNE @loop
@exit:
	RTS

update_vram:
	LDA #$00		; Set to Clear
	LDX BUFFER_LENGTH	; Get Buffer Length
	STA __BUFFER_LOAD__+0,X	; Store 0 at End
	STA BUFFER_LENGTH	; Clear Buffer Length
	TAY			; Set to First Byte in Buffer
@next:
	LDA __BUFFER_LOAD__+0,Y	; Get Data Length
	BEQ @end		; End?
	STA VRAM_INCREMENT	; Get VRAM Increment Flag and Repeat Flag
	AND #%00111111		; Remove VRAM Increment Flag and Repeat Flag
	TAX			; Set X to Data Length
	LDA SOFT_2000		; Get $2000 Settings
	AND #%11111011		; Set VRAM Increment to Across
	BIT VRAM_INCREMENT	; Check VRAM Increment Flag
	BPL @inc
	ORA #%00000100		; Set VRAM Increment to Down
@inc:
	STA $2000		; Store VRAM Increment
	LDA __BUFFER_LOAD__+2,Y	; Get VRAM Address Hi Byte
	STA $2006		; Store VRAM Address Hi Byte
	LDA __BUFFER_LOAD__+1,Y	; Get VRAM Address Lo Byte
	STA $2006		; Store VRAM Address Lo Byte
	INY			; Set Y + 3 to First Data Byte
	INY
	; Store Data in VRAM (V clear = X Data, V set = repeat Data X times)
	BVC @loop		; Check Repeat Flag
	INY
@loop:
	BVS @store		; Repeat?
	INY
@store:
	LDA __BUFFER_LOAD__+0,Y	; Get Data
	STA $2007		; Store Data in VRAM
	DEX			; Next Byte
	BNE @loop
	INY			; Check Next in Buffer
	JMP @next
@end:
	RTS

update_scroll:
	LDA SOFT_2000		; Set Name Table
	STA $2000
	LDA XSCROLL		; Set Horizontal Scroll Offset
	STA $2005
	LDA YSCROLL		; Set Vertical Scroll Offset
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
	.BYTE $22,$29,$1A,$0F, $22,$36,$17,$0F, $22,$30,$21,$0F, $22,$27,$17,$0F
	.BYTE $22,$16,$27,$18, $22,$1A,$30,$27, $22,$16,$30,$27, $22,$0F,$36,$17

fade_in:
	LDA FADE		; Current Fade Timer
	CMP #$0F		; End of Fade In?
	BCS @done
	INC FADE		; Increase Fade Timer
	JSR buffer_palette
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
	JSR buffer_palette
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

buffer_palette:
	LDX BUFFER_LENGTH	; Get Current Buffer Length
	STX BUFFER_END		; Store X as Buffer End
	LDA #<$3F00		; Get VRAM Address Lo Byte
	STA __BUFFER_LOAD__+1,X	; Store VRAM Address Lo Byte in Buffer
	LDA #>$3F00		; Get VRAM Address Hi Byte
	STA __BUFFER_LOAD__+2,X	; Store VRAM Address Hi Byte in Buffer
	LDX #$00		; Set Index to First Color
:	LDA __PALETTE_LOAD__,X	; Get Color
	AND #$F0		; Keep Color Hi Nibble (Brightness)
	ORA FADE		; Set Fade Timer Lo Nibble
	TAY			; Set as Index
	LDA __PALETTE_LOAD__,X	; Load Color
	AND #$0F		; Keep Color Lo Nibble
	ORA PALETTE_FADE,Y	; Set Color Hi Nibble
	STA __BUFFER_LOAD__+3,X	; Store Color in Buffer
	INX			; Next Color
	CPX #$20		; Continue until Last Color
	BNE :-
	TXA			; Get Length
	CLC
	ADC BUFFER_LENGTH	; Add Buffer Length
	LDX BUFFER_END		; Set Index to Original End
	STA __BUFFER_LOAD__+0,X	; Store Bytes Used into Buffer
	CLC
	ADC BUFFER_END		; Add Bytes Used to Buffer End
	ADC #$03		; Add VRAM Address and Length Bytes
	STA BUFFER_LENGTH	; Store New Buffer Length
	RTS

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
	STX TEMP+0		; Store Source Lo Byte
	STY TEMP+1		; Store Source Hi Byte
	STA TEMP+2		; Store Source Length
	; Clear OAM Buffer
	LDY #$00
	LDA #$F0		; Set Y Position to off-screen
:	STA __SPRITE_LOAD__,Y	; Store Y Position in OAM Buffer
	INY			; Set to next sprite
	INY
	INY
	INY
	BNE :-			; Last sprite?
	; Load Sprites into OAM Buffer
:	LDA (TEMP),Y		; Get Sprite Attribute
	STA __SPRITE_LOAD__,Y	; Store in OAM Buffer
	INY			; Next Sprite Attribute
	CPY TEMP+2		; Last Sprite Attribute?
	BNE :-
	RTS

title_sprites:
	.BYTE $C0,$3A,%00000000,$28
	.BYTE $C0,$37,%00000000,$30
	.BYTE $C8,$4F,%00000000,$28
	.BYTE $C8,$4F,%01000000,$30
title_sprites_end:

;----------------;
; JOYPAD SECTION ;
;----------------;

update_joypad:
	; Joypad Strobing
	LDA #$01
	STA $4016		; Set Strobe
	LDA #$00
	STA $4016		; Clear Strobe
	; Read Joypad 1
	LDX JOYRAW1		; Previous Joypad 1 Read
	LDY #$08		; Set to read 8 buttons
:	LDA $4016		; Get Joypad 1 Button
	LSR			; Set Button in Carry
	ROL JOYRAW1		; Set Button in Raw Data
	AND #%00000001		; Famicon Expansion Port 3 Button
	ORA JOYRAW1		; Set Famicon Button in Raw Data
	STA JOYRAW1		; Store Raw Data
	DEY			; Next Button
	BNE :-			; Last Button?
	; Pressed Button Check
	TXA			; Previous Joypad Read
	EOR JOYRAW1		; Find Button Changes
	AND JOYRAW1		; Find New Button Changes
	STA JOYPRESS1		; Store Pressed Buttons
	; Held Button Check
	TXA			; Previous Joypad Read
	AND JOYRAW1		; Find Same Buttons
	STA JOYHELD1		; Store Held Buttons
	; Read Joypad 2
	LDX JOYRAW2		; Previous Joypad 2 Read
	LDY #$08		; Set to read 8 buttons
:	LDA $4017		; Get Joypad 2 Button
	LSR			; Set Button in Carry
	ROL JOYRAW2		; Set Button in Raw Data
	AND #%00000001		; Famicon Expansion Port 4 Button
	ORA JOYRAW2		; Set Famicon Button in Raw Data
	STA JOYRAW2		; Store Raw Data
	DEY			; Next Button
	BNE :-			; Last Button?
	; Pressed Button Check
	TXA			; Previous Joypad Read
	EOR JOYRAW2		; Find Button Changes
	AND JOYRAW2		; Find New Button Changes
	STA JOYPRESS2		; Store Pressed Buttons
	; Held Button Check
	TXA			; Previous Joypad Read
	AND JOYRAW2		; Find Same Buttons
	STA JOYHELD2		; Store Held Buttons
	RTS

;--------------------;
; BACKGROUND SECTION ;
;--------------------;

load_title_vram:
	LDX #<title_name_table		; Source Lo Byte
	LDY #>title_name_table		; Source Hi Byte
	JSR load_vram
	LDX #<title_attribute_table	; Source Lo Byte
	LDY #>title_attribute_table	; Source Hi Byte
	JSR load_vram
	RTS

load_vram:
	STX TEMP+0		; Store Source Lo
	STY TEMP+1		; Store Source Hi
	LDY #$00		; Set to First Byte of Source Address
@next:
	INY			; Set to VRAM Address Hi Byte
	LDA (TEMP),Y		; Get VRAM Address Hi Byte
	AND #%11000000		; Get VRAM Increment Flag
	STA VRAM_INCREMENT	; Store VRAM Increment Flag
	LDA SOFT_2000		; Get $2000 Settings
	AND #%11111011		; Set VRAM Increment to Across
	BIT VRAM_INCREMENT	; Check VRAM Increment Flag
	BPL @inc
	ORA #%00000100		; Set VRAM Increment to Down
@inc:
	STA $2000		; Store VRAM Increment
	LDA (TEMP),Y		; Get VRAM Address Hi Byte
	AND #%00111111		; Remove VRAM Increment Flag
	STA $2006		; Store VRAM Address Hi Byte
	DEY
	LDA (TEMP),Y		; Get VRAM Address Lo Byte
	STA $2006		; Store VRAM Address Lo Byte
	INY
	INY
@store:
	LDA (TEMP),Y		; Get Source Data
	CMP #$FE		; Check for Control Bytes
	BCS @end
	STA $2007		; Store Byte into VRAM
	INY			; Next Byte
	BNE @store		; Wrap?
	INC TEMP+1		; Increase Source Hi Byte
	JMP @store
@end:
	CMP #$FF		; Check for End Control Byte
	BNE @next
	RTS


title_name_table:
	.BYTE $00,$20
	.BYTE $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
	.BYTE $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
	.BYTE $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
	.BYTE $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
	.BYTE $24,$24,$24,$24,$24,$24,$24,$24,$36,$37,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
	.BYTE $24,$24,$24,$24,$24,$24,$24,$35,$25,$25,$38,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
	.BYTE $24,$24,$24,$24,$24,$24,$24,$39,$3A,$3B,$3C,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$36,$37,$36,$37,$36,$37,$24,$24
	.BYTE $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$35,$25,$25,$25,$25,$25,$25,$38,$24
	.BYTE $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$39,$3A,$3B,$3A,$3B,$3A,$3B,$3C,$24
	.BYTE $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
	.BYTE $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$53,$54,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
	.BYTE $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$55,$56,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
	.BYTE $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
	.BYTE $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
	.BYTE $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
	.BYTE $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
	.BYTE $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
	.BYTE $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
	.BYTE $53,$54,$24,$24,$24,$24,$24,$24,$45,$45,$53,$54,$45,$45,$53,$54,$45,$45,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
	.BYTE $55,$56,$24,$24,$24,$24,$24,$24,$47,$47,$55,$56,$47,$47,$55,$56,$47,$47,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
	.BYTE $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
	.BYTE $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
	.BYTE $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$60,$61,$62,$63,$24,$24,$24,$24
	.BYTE $24,$24,$31,$32,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$64,$65,$66,$67,$24,$24,$24,$24
	.BYTE $24,$30,$26,$34,$33,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$36,$37,$24,$24,$24,$24,$24,$24,$68,$69,$26,$6A,$24,$24,$24,$24
	.BYTE $30,$26,$26,$26,$26,$33,$24,$24,$24,$24,$24,$24,$24,$24,$24,$35,$25,$25,$38,$24,$24,$24,$24,$24,$68,$69,$26,$6A,$24,$24,$24,$24
	.BYTE $B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5
	.BYTE $B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7
	.BYTE $B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5,$B4,$B5
	.BYTE $B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7,$B6,$B7
	.BYTE $FF

title_attribute_table:
	.BYTE $C0,$23
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $00,$88,$AA,$00,$00,$80,$A0,$A0
	.BYTE $00,$00,$00,$30,$00,$08,$0A,$0A
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $30,$00,$D0,$D0,$10,$00,$00,$00
	.BYTE $00,$00,$00,$00,$00,$00,$00,$00
	.BYTE $50,$50,$50,$50,$50,$50,$50,$50
	.BYTE $05,$05,$05,$05,$05,$05,$05,$05
	.BYTE $FF

buffer_vram:
	STX TEMP+0		; Store VRAM Address Lo
	STY TEMP+1		; Store VRAM Address Hi
	STA TEMP+2  		; Store Source Length
	LDX BUFFER_LENGTH	; Get Current Buffer Length
	STX BUFFER_END		; Store X as Buffer End
	LDA TEMP+0		; Get VRAM Address Lo Byte
	STA __BUFFER_LOAD__+1,X	; Store VRAM Address Lo Byte in Buffer
	LDA TEMP+1		; Get VRAM Address Hi Byte
	AND #%11000000		; Get VRAM Increment and Repeat Flag
	STA VRAM_INCREMENT	; Store VRAM Increment and Repeat Flag
	LDA TEMP+1		; Get VRAM Address Hi Byte
	AND #%00111111		; Remove VRAM Increment and Repeat Flag
	STA __BUFFER_LOAD__+2,X	; Store VRAM Address Hi Byte in Buffer
	LDY #$00		; Set to First Byte of Source Address
	BIT VRAM_INCREMENT	; Check for Repeat Flag
	BVS @repeat
@next:
	LDA (SOURCE),Y		; Get Source Data
	CPY TEMP+2		; Last Byte?
	BEQ @length
	STA __BUFFER_LOAD__+3,X	; Store Byte into Buffer
	INY			; Next Byte
	INX			; Next Byte in Buffer
	JMP @next
@length:
	TXA			; Get Length
	SEC
	SBC BUFFER_END		; Subtract Length from Buffer End
	ORA VRAM_INCREMENT	; Add VRAM Increment and Repeat Flag
	LDX BUFFER_END		; Set Index to Original End
	STA __BUFFER_LOAD__+0,X	; Store Bytes Used into Buffer
	AND #%00111111		; Remove VRAM Increment and Repeat Flag
	JMP @end
@repeat:
	LDA (SOURCE),Y		; Get Source Data
	STA __BUFFER_LOAD__+3,X	; Store Byte into Buffer
	LDA TEMP+2		; Set Data Length
	ORA VRAM_INCREMENT	; Add VRAM Increment and Repeat Flag
	LDX BUFFER_END		; Set Index to Original End
	STA __BUFFER_LOAD__+0,X	; Store Data Length into Buffer
	LDA #$01		; Set To Bytes Used
@end:
	CLC
	ADC BUFFER_END		; Add Bytes Used to Buffer End
	ADC #$03		; Add VRAM Address and Length Bytes
	STA BUFFER_LENGTH	; Store New Buffer Length
	RTS

message:
	.BYTE $1D,$0E,$0C,$16,$18,$0B,$18,$20,$15,$28,$18,$1B,$10
message_end:

message_color:
	.BYTE %10100000,%10100000,%10100000,%00100000
message_color_end:

restore:			; REPEAT
	.BYTE $24

restore_color:			; REPEAT
	.BYTE %00000000

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
	.incbin "./resources/mario.chr"
