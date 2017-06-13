;===============================================================================
.segment "HEADER"
;=====================
	.BYTE "NES", $1A	; NES^Z
	.BYTE 1				; #16 KB PRG ROM Banks
	.BYTE 1				; #8 KB CHR ROM Banks
	.BYTE %00000001		; ROM Control Byte #1
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
XSCROLL:	.res 2
X_DIRECTION:	.res 1
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
VRAM_ADDRESS:	.res 2
DRAW_WIDTH:	.res 1
DRAW_HEIGHT:	.res 1
TEMP:		.res 3
X_DRAW:		.res 1

ANIMATION:	.res 2
SPRITE_ANIMATION:	.res 1
SPRITE_FRAME_SUB:	.res 1
SPRITE_FRAME:		.res 1
SPRITE_Y:		.res 1
SPRITE_X_SUB:		.res 1
SPRITE_X_LO:		.res 1
SPRITE_X_HI:		.res 1
SPRITE_X_DELTA:		.res 2
SPRITE_ATTRIBUTE:	.res 1
SPRITE_HEIGHT:		.res 1

OAM_USED:	.res 1

ENEMY_Y:	.res 1
ENEMY_X_LO:	.res 1
ENEMY_X_HI:	.res 1
DISTANCE:	.res 2

;===============================================================================
.segment "SPRITE"
;=====================
.import __SPRITE_LOAD__
ZERO:		.res 4
MARIO:		.res 16
GOOMBA:		.res 16

;===============================================================================
.segment "PALETTE"
;=====================
.import __PALETTE_LOAD__

;===============================================================================
.segment "BUFFER"
;=====================
.import __BUFFER_LOAD__

;===============================================================================
.segment "DATA"
;=====================
.import __DATA_LOAD__
MARIO_DATA:		.res 11
GOOMBA_DATA:	.res 11

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
	JSR setMario
	JSR setGoomba
	JSR fade_in		; Fade Screen to Full Color
game_loop:
:	LDA DRAW_FLAG		; Wait for Previous Draw
	BNE :-
	LDA XSCROLL+0
	AND #%00011111
	STA X_DRAW
	JSR updateMario
	JSR updateGoomba
	JSR collision_check
	JSR scroll_check
	LDA #$04
	STA OAM_USED
	JSR clear_sprite
	LDX #$00
:	JSR loadData
	TXA
	PHA
	JSR animation
	PLA
	TAX
	JSR storeData
	INX
	CPX #$02
	BNE :-
	LDA #TRUE
	STA DRAW_FLAG
	JMP game_loop

updateGoomba:
	LDX #$01
	JSR loadData
	LDA #$30
	LSR
	STA TEMP+2
	LSR
	LSR
	ADC TEMP+2
	ADC SPRITE_FRAME_SUB
	STA SPRITE_FRAME_SUB
	LDA SPRITE_FRAME
	ADC #$00
	STA SPRITE_FRAME
	LDX #$01
	JSR storeData
	RTS

updateMario:
	LDX #$00
	JSR loadData
	JSR move_mario
	LDX #$00
	JSR storeData
	RTS

move_mario:
@left:
	LDA JOYRAW1		; Left Button?
	AND #LEFT_BUTTON
	BEQ @right
	LDA SPRITE_X_DELTA+1	; Leftward Velocity?
	BMI @leftwalk
	LDA SPRITE_X_DELTA+0	; No Velocity?
	BNE @leftbrake
	LDA SPRITE_X_DELTA+1
	BEQ @leftwalk
@leftbrake:
	JSR brakeleft		; Brake the Walk Right
	JMP @frame
@leftwalk:
	JSR walkleft		; Walk Left
	JMP @frame
@right:
	LDA JOYRAW1		; Right Button?
	AND #RIGHT_BUTTON
	BEQ @none
	LDA SPRITE_X_DELTA+1	; Rightward/No Velocity?
	BPL @rightwalk
@rightbrake:
	JSR brakeright		; Brake the Walk Left
	JMP @frame
@rightwalk:
	JSR walkright		; Walk Right
	JMP @frame
@none:
	JSR brake		; Decelerate Walk
@frame:
	LDA SPRITE_X_DELTA+1	; Velocity Direction?
	BPL @forward
@backward:
	LDA #$00		; Get Absolute Velocity
	SEC
	SBC SPRITE_X_DELTA+0
	STA TEMP+2
	LDA #$00
	SBC SPRITE_X_DELTA+1
	LSR
	LDA TEMP+2
	JMP @doframe
@forward:
	LDA SPRITE_X_DELTA+1
	LSR
	LDA SPRITE_X_DELTA+0
@doframe:
	ROR			; Velocity * 5/16 + Previous Frame = Current Frame
	LSR
	STA TEMP+2
	LSR
	LSR
	ADC TEMP+2
	ADC SPRITE_FRAME_SUB
	STA SPRITE_FRAME_SUB
	LDA SPRITE_FRAME
	ADC #$00
	STA SPRITE_FRAME
	JSR x_bg_collision	; Do Movement Collision Check
	RTS

walkleft:
	LDA SPRITE_ANIMATION	; Walking?
	CMP #$01
	BEQ @walk
	JSR setWalking
	LDA SPRITE_ATTRIBUTE	; Set Horizontal Flip Bit to Left
	ORA #$40
	STA SPRITE_ATTRIBUTE
@walk:
	LDA SPRITE_X_LO		; Move Left?
	CMP #<$0004
	LDA SPRITE_X_HI
	SBC #>$0004
	BCC @done
	LDA SPRITE_X_DELTA+0	; Accelerate to the Left
	SEC
	SBC #<$000E		; Acceleration Lo
	STA SPRITE_X_DELTA+0
	LDA SPRITE_X_DELTA+1
	SBC #>$000E		; Acceleration Hi
	STA SPRITE_X_DELTA+1
	LDA SPRITE_X_DELTA+0	; Reached Max Speed?
	CMP #<$FEB4
	LDA SPRITE_X_DELTA+1
	SBC #>$FEB4
	BCS @move
	LDA #<$FEB4		; Set to Max Speed
	STA SPRITE_X_DELTA+0
	LDA #>$FEB4
	STA SPRITE_X_DELTA+1
@move:
	JSR negativeVelocity
@done:
	RTS

brakeleft:
	LDA SPRITE_ANIMATION	; Braking?
	CMP #$02
	BEQ @braking
	JSR setBraking
	LDA SPRITE_ATTRIBUTE	; Set Horizontal Flip Bit to Left
	ORA #$40
	STA SPRITE_ATTRIBUTE
@braking:
	LDA SPRITE_X_DELTA+0	; Decelerate Right Movement
	SEC
	SBC #<$000D		; Deceleration Lo
	STA SPRITE_X_DELTA+0
	LDA SPRITE_X_DELTA+1
	SBC #>$000D		; Deceleration Hi
	STA SPRITE_X_DELTA+1
	LDA SPRITE_X_DELTA+0	; Reached Stop?
	CMP #<$0000
	LDA SPRITE_X_DELTA+1
	SBC #>$0000
	BPL @slide
	JSR setStanding
@slide:
	LDA SPRITE_X_LO		; Move Right?
	CMP #<$03F0
	LDA SPRITE_X_HI
	SBC #>$03F0
	BCS @done
	JSR positiveVelocity
@done:
	RTS

walkright:
	LDA SPRITE_ANIMATION	; Walking?
	CMP #$01
	BEQ @walk
	JSR setWalking
	LDA SPRITE_ATTRIBUTE	; Set Horizontal Flip Bit to Right
	AND #$40				; #~$40
	STA SPRITE_ATTRIBUTE
@walk:
	LDA SPRITE_X_LO		; Move Right?
	CMP #<$03F0
	LDA SPRITE_X_HI
	SBC #>$03F0
	BCS @done
	LDA SPRITE_X_DELTA+0	; Accelerate to the Right
	CLC
	ADC #<$000E		; Acceleration Lo
	STA SPRITE_X_DELTA+0
	LDA SPRITE_X_DELTA+1
	ADC #>$000E		; Acceleration Hi
	STA SPRITE_X_DELTA+1
	LDA SPRITE_X_DELTA+0	; Reached Max Speed?
	CMP #<$014C
	LDA SPRITE_X_DELTA+1
	SBC #>$014C
	BCC @move
	LDA #<$014C		; Set to Max Speed
	STA SPRITE_X_DELTA+0
	LDA #>$014C
	STA SPRITE_X_DELTA+1
@move:
	JSR positiveVelocity
@done:
	RTS

brakeright:
	LDA SPRITE_ANIMATION	; Braking?
	CMP #$02
	BEQ @braking
	JSR setBraking
	LDA SPRITE_ATTRIBUTE	; Set Horizontal Flip to Right
	AND #$40				; #~$40
	STA SPRITE_ATTRIBUTE
@braking:
	LDA SPRITE_X_DELTA+0	; Decelerate Left Movement
	CLC
	ADC #<$000D		; Deceleration Lo
	STA SPRITE_X_DELTA+0
	LDA SPRITE_X_DELTA+1
	ADC #>$000D		; Deceleration Hi
	STA SPRITE_X_DELTA+1
	LDA SPRITE_X_DELTA+0	; Reached Stop?
	CMP #<$0000
	LDA SPRITE_X_DELTA+1
	SBC #>$0000
	BMI @slide
	JSR setStanding
	JSR positiveVelocity
	JMP @done
@slide:
	LDA SPRITE_X_LO		; Move Left?
	CMP #<$0004
	LDA SPRITE_X_HI
	SBC #>$0004
	BCC @done
	JSR negativeVelocity
@done:
	RTS

brake:
	LDA SPRITE_ANIMATION	; Stopped?
	BEQ @done
	LDA SPRITE_X_DELTA+1	; Newly Stopped?
	BNE @brake
	LDA SPRITE_X_DELTA+0
	BNE @brake
	JSR setStanding
	JMP @done
@brake:
	LDA SPRITE_X_DELTA+1	; Decelerate in what direction?
	BPL @right
@left:
	LDA SPRITE_X_DELTA+0	; Decelerate Left
	CLC
	ADC #<$000D		; Deceleration Lo
	STA SPRITE_X_DELTA+0
	LDA SPRITE_X_DELTA+1
	ADC #>$000D		; Deceleration Hi
	STA SPRITE_X_DELTA+1
	LDA SPRITE_X_DELTA+0	; Reached Stop?
	CMP #<$0000
	LDA SPRITE_X_DELTA+1
	SBC #>$0000
	BMI @slowleft
	JSR setStanding
	JSR positiveVelocity
	JMP @done
@slowleft:
	LDA SPRITE_X_LO		; Move Left?
	CMP #<$0004
	LDA SPRITE_X_HI
	SBC #>$0004
	BCC @done
	JSR negativeVelocity
	JMP @done
@right:
	LDA SPRITE_X_DELTA+0	; Decelerate Right
	SEC
	SBC #<$000D		; Deceleration Lo
	STA SPRITE_X_DELTA+0
	LDA SPRITE_X_DELTA+1
	SBC #>$000D		; Deceleration Hi
	STA SPRITE_X_DELTA+1
	LDA SPRITE_X_DELTA+0	; Reached Stop?
	CMP #<$0000
	LDA SPRITE_X_DELTA+1
	SBC #>$0000
	BPL @slowright
	JSR setStanding
@slowright:
	LDA SPRITE_X_LO		; Move Right?
	CMP #<$03F0
	LDA SPRITE_X_HI
	SBC #>$03F0
	BCS @done
	JSR positiveVelocity
@done:
	RTS

negativeVelocity:
	DEC SPRITE_X_HI		; Negative Velocity Sign Extend
positiveVelocity:
	LDA SPRITE_X_SUB	; New Sprite Location = Sprite Location + Velocity
	CLC
	ADC SPRITE_X_DELTA+0
	STA SPRITE_X_SUB
	LDA SPRITE_X_LO
	ADC SPRITE_X_DELTA+1
	STA SPRITE_X_LO
	LDA SPRITE_X_HI
	ADC #$00
	STA SPRITE_X_HI
	RTS

scroll_check:
	LDA #$00		; Clear Direction
	STA X_DIRECTION
	JSR move		; Check Movement
	JSR column_check	; New Column?
	JSR attribute_check	; New Attribute?
	RTS

move:
	LDA SPRITE_X_LO		; Get Main Object Location
	SEC
	SBC XSCROLL+0
	TAY
	LDA SPRITE_X_HI
	SBC XSCROLL+1
	BMI @leftmax		; Past Left of Screen
	BNE @rightmax		; Past Right of Screen
	TYA			; Hit Left Window?
	SEC
	SBC #$62
	BCC @lefttrap
	TYA			; Hit Right Window?
	SEC
	SBC #$82
	BCC @exit
@righttrap:
	CMP #$04		; Scroll Speed Right
	BCC @right
@rightmax:
	LDA #$04		; Set Max Scroll Speed
@right:
	TAX
	LDA XSCROLL+0		; Max Scroll Right?
	CMP #<$02FF
	LDA XSCROLL+1
	SBC #>$02FF
	BCS @exit
	TXA
	STA X_DIRECTION		; Change Scroll by Speed
	CLC
	ADC XSCROLL+0
	STA XSCROLL+0
	LDA XSCROLL+1
	ADC #$00
	STA XSCROLL+1
	RTS
@lefttrap:
	CMP #$FC		; Scroll Speed Left
	BCS @left
@leftmax:
	LDA #$FC		; Set Max Scroll Speed
@left:
	TAX
	LDA XSCROLL+0		; Max Scroll Left?
	CMP #<$0003
	LDA XSCROLL+1
	SBC #>$0003
	BCC @exit
	TXA
	STA X_DIRECTION		; Change Scroll by Speed
	CLC
	ADC XSCROLL+0
	STA XSCROLL+0
	LDA XSCROLL+1
	SBC #$00
	STA XSCROLL+1
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
	STA XSCROLL+0		; Set X Scroll
	STA XSCROLL+1
	; Set Other Variables Here
	STA FADE		; Set Fade
	RTS

init_graphics:
	; Load Initial Screen Here
	JSR load_title_palette	; Load Title Palette
	JSR load_title_sprites	; Load Title Sprites
	JSR load_name_table	; Load Title Background
	JSR load_status_bar	; Load Status Bar
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
	JSR update_status	; Update Status Bar
	LDA SOFT_2001		; Enable Screen
	STA $2001
	JSR update_scroll	; Update Scroll
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

update_status:
	LDA SOFT_2000
	AND #%11111100
	STA $2000
	LDA #$00
	STA $2005
	LDA #$00
	STA $2005
	RTS

update_scroll:
@hit:
	BIT $2002		; Wait Until Sprite #0 Not Hit
	BVS @hit
@nothit:
	BIT $2002		; Wait Until Sprite #0 Hit
	BVC @nothit
	LDX #$14		; Wait for End of Scanline
@delay:
	DEX
	BNE @delay
	LDA SOFT_2000
	AND #%11111100
	STA SOFT_2000
	LDA XSCROLL+1
	AND #%00000001
	ORA SOFT_2000		; Set Name Table
	STA SOFT_2000
	STA $2000
	LDA XSCROLL+0		; Set Vertical Scroll Offset
	STA $2005
	LDA YSCROLL		; Set Horizontal Scroll Offset
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
	.BYTE $18,$FF,%00100011,$58	; Sprite #0
	.BYTE $C0,$3A,%00000000,$28	; Mario
	.BYTE $C0,$37,%00000000,$30
	.BYTE $C8,$4F,%00000000,$28
	.BYTE $C8,$4F,%01000000,$30
	.BYTE $C0,$70,%00000011,$09	; Goomba
	.BYTE $C0,$71,%00000011,$11
	.BYTE $C8,$72,%00000011,$09
	.BYTE $C8,$73,%00000011,$11
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

;---------------------------;
; BACKGROUND SCROLL SECTION ;
;---------------------------;

load_name_table:
	LDA #$21		; Set Columns to Draw
	STA DRAW_WIDTH
@column:
	LDX XSCROLL+0		; X Lo
	LDY XSCROLL+1		; X Hi
	JSR get_column		; Get Name Table and Source Addresses
	LDA #$1A		; Number of Tiles in Column
	STA DRAW_HEIGHT
	JSR draw_column		; Draw Column to VRAM
	LDX XSCROLL+0		; X Lo
	LDY XSCROLL+1		; X Hi
	JSR get_attribute	; Get Attribute Table and Source Addresses
	JSR draw_attribute	; Draw Attribute to VRAM
	LDA XSCROLL+0		; Next Column
	CLC
	ADC #<$0008
	STA XSCROLL+0
	LDA XSCROLL+1
	ADC #>$0008
	STA XSCROLL+1
	DEC DRAW_WIDTH		; Last Column?
	BNE @column
	LDA XSCROLL+0		; Set to Original Location
	SEC
	SBC #<$0108
	STA XSCROLL+0
	LDA XSCROLL+1
	SBC #>$0108
	STA XSCROLL+1
	RTS

get_column:
	; Get Name Table Address
	TXA			; X Lo / 8 = Name Table Address Lo
	LSR
	LSR
	LSR
	STA VRAM_ADDRESS+0
	TYA			; X Hi
	AND #%00000001		; Keep Name Table Side
	ASL			; Name Table Side * 4 + $20 = Name Table Address Hi
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
	LDA XSCROLL+0		; X / 8 = Column
	STA SOURCE+0
	LDA XSCROLL+1
	STA SOURCE+1
	LSR SOURCE+1
	ROR SOURCE+0
	LSR SOURCE+1
	ROR SOURCE+0
	LSR SOURCE+1
	ROR SOURCE+0
	ASL SOURCE+0		; (Column * 32) - (Column * 6) = Source Index
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
	LDA SOURCE+0		; Source Index + Source = Source Address
	CLC
	ADC #<title_name_table
	STA SOURCE+0
	LDA SOURCE+1
	ADC #>title_name_table
	STA SOURCE+1
	RTS

draw_column:
	LDA SOFT_2000		; Get $2000 Settings
	ORA #%00000100		; Set VRAM Increment Down
	STA $2000		; Store VRAM Increment
	LDA VRAM_ADDRESS+1	; Store VRAM Address
	STA $2006
	LDA VRAM_ADDRESS+0
	STA $2006
	LDX DRAW_HEIGHT		; Set Tiles to Draw
	LDY #$00
:	LDA (SOURCE),Y		; Store Tile in VRAM
	STA $2007
	INY			; Next Tile
	DEX			; Last Tile?
	BNE :-
	RTS

get_attribute:
	; Get Attribute Table Address
	TXA			; X Lo / 32 + $C0 = Attribute Table Address Lo
	LSR
	LSR
	LSR
	LSR
	LSR
	CLC
	ADC #<$23C0
	STA VRAM_ADDRESS+0
	TYA			; X Hi
	AND #%00000001		; Keep Name Table Side
	ASL			; Name Table Side * 4 + $23 = Attribute Table Address Hi
	ASL
	ADC #>$23C0
	STA VRAM_ADDRESS+1
	; Get Source Index
	LDA XSCROLL+0		; X / 32 = Column
	STA SOURCE+0
	LDA XSCROLL+1
	STA SOURCE+1
	LSR SOURCE+1
	ROR SOURCE+0
	LSR SOURCE+1
	ROR SOURCE+0
	LSR SOURCE+1
	ROR SOURCE+0
	LSR SOURCE+1
	ROR SOURCE+0
	LSR SOURCE+1
	ROR SOURCE+0
	ASL SOURCE+0		; Column * 8 = Source Index
	ROL SOURCE+1
	ASL SOURCE+0
	ROL SOURCE+1
	ASL SOURCE+0
	ROL SOURCE+1
	; Get Source Address
	LDA SOURCE+0		; Source Index + Source = Source Address
	CLC
	ADC #<title_attribute_table
	STA SOURCE+0
	LDA SOURCE+1
	ADC #>title_attribute_table
	STA SOURCE+1
	RTS

draw_attribute:
	LDY #$00		; Set to First Attribute
@loop:
	LDA VRAM_ADDRESS+1	; Store VRAM Address
	STA $2006
	LDA VRAM_ADDRESS+0
	STA $2006
	LDA (SOURCE),Y		; Store Attribute in VRAM
	STA $2007
	INY			; Next Attribute
	CPY #$08		; Last Attribute?
	BEQ @exit
	LDA VRAM_ADDRESS+0	; Next VRAM Address
	CLC
	ADC #$08
	STA VRAM_ADDRESS+0
	JMP @loop
@exit:
	RTS

column_check:
	LDA XSCROLL+0		; Moved 8 pixels?
	AND #%00000111
	CMP X_DRAW
	BEQ @exit
	LDA X_DIRECTION		; No Movement?
	BEQ @exit
	BPL @right		; Moved Left or Right?
@left:
	LDA XSCROLL+0		; Set to New Column
	SEC
	SBC #<$0010
	STA XSCROLL+0
	TAX
	LDA XSCROLL+1
	SBC #>$0010
	STA XSCROLL+1
	TAY
	JSR get_column		; Get Name Table and Source Addresses
	JSR buffer_column	; Buffer Column
	LDA XSCROLL+0		; Set to Current Column
	CLC
	ADC #<$0010
	STA XSCROLL+0
	LDA XSCROLL+1
	ADC #>$0010
	STA XSCROLL+1
	JMP @exit
@right:
	LDA XSCROLL+0		; Set to New Column
	CLC
	ADC #<$0100
	STA XSCROLL+0
	TAX
	LDA XSCROLL+1
	ADC #>$0100
	STA XSCROLL+1
	TAY
	JSR get_column		; Get Name Table and Source Addresses
	JSR buffer_column	; Buffer Column
	LDA XSCROLL+0		; Set to Current Column
	SEC
	SBC #<$0100
	STA XSCROLL+0
	LDA XSCROLL+1
	SBC #>$0100
	STA XSCROLL+1
@exit:
	RTS

buffer_column:
	LDX VRAM_ADDRESS+0	; Set VRAM Address Lo
	LDA VRAM_ADDRESS+1	; Set VRAM Address Hi
	CLC
	ADC #%10000000		; Add VRAM Increment Down
	TAY
	LDA #$1A		; Set Number of Rows in Column
	JSR buffer_vram
	RTS

attribute_check:
	LDA XSCROLL+0		; Moved 32 pixels?
	AND #%00011111
	CMP X_DRAW
	BEQ @exit
	LDA X_DIRECTION		; No Movement?
	BEQ @exit
	BPL @right		; Left or Right?
@left:
	LDA XSCROLL+0		; Set to New Column
	SEC
	SBC #<$0010
	STA XSCROLL+0
	TAX
	LDA XSCROLL+1
	SBC #>$0010
	STA XSCROLL+1
	TAY
	JSR get_attribute	; Get Attribute Table and Source Addresses
	JSR buffer_attribute	; Buffer Attribute
	LDA XSCROLL+0		; Set to Current Column
	CLC
	ADC #<$0010
	STA XSCROLL+0
	LDA XSCROLL+1
	ADC #>$0010
	STA XSCROLL+1
	JMP @exit
@right:
	LDA XSCROLL+0		; Set to New Column
	CLC
	ADC #<$0100
	STA XSCROLL+0
	TAX
	LDA XSCROLL+1
	ADC #>$0100
	STA XSCROLL+1
	TAY
	JSR get_attribute	; Get Attribute Table and Source Addresses
	JSR buffer_attribute	; Buffer Attribute
	LDA XSCROLL+0		; Set to Current Column
	SEC
	SBC #<$0100
	STA XSCROLL+0
	LDA XSCROLL+1
	SBC #>$0100
	STA XSCROLL+1
@exit:
	RTS

buffer_attribute:
	LDY #$00		; Set Attribute Row Index
@loop:
	TYA			; Store Attribute Row Index
	PHA
	LDX VRAM_ADDRESS+0	; Set VRAM Address Lo
	LDY VRAM_ADDRESS+1	; Set VRAM Address Hi
	LDA #$01		; Set Number of Attributes
	JSR buffer_vram
	PLA			; Get Attribute Row Index
	TAY
	INY			; Next Attribute Row
	CPY #$08		; Last Attribute Row?
	BEQ @exit
	LDA VRAM_ADDRESS+0	; Next Attribute Row Address
	CLC
	ADC #$08
	STA VRAM_ADDRESS+0
	INC SOURCE+0		; Next Source Address
	BNE @loop
	INC SOURCE+1
	JMP @loop
@exit:
	RTS

title_name_table:
	.incbin "./resources/SMBlevel1_0.bin"

title_attribute_table:
	.incbin "./resources/SMBattrib.bin"

;--------------------;
; STATUS BAR SECTION ;
;--------------------;

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
	.BYTE $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
	.BYTE $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
	.BYTE $24,$24,$24,$16,$0A,$1B,$12,$18,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$20,$18,$1B,$15,$0D,$24,$24,$1D,$12,$16,$0E,$24,$24,$24
	.BYTE $24,$24,$24,$00,$00,$00,$00,$00,$00,$24,$24,$2E,$29,$00,$00,$24,$24,$24,$24,$01,$28,$01,$24,$24,$24,$24,$02,$03,$06,$24,$24,$24
status_bar_end:

;-------------------;
; ANIMATION SECTION ;
;-------------------;

animation_index:
	.WORD mario_standing	; $00
	.WORD mario_walking	; $01
	.WORD mario_skidding	; $02
	.WORD mario_jumping	; $03
	.WORD mario_swimming	; $04
	.WORD mario_climbing	; $05
	.WORD mario_killed	; $06
	.WORD goomba_stand	; $07

mario_standing:
	.WORD mario_standing0
	.WORD animation_loop

mario_walking:
	.WORD mario_walking0
	.WORD mario_walking1
	.WORD mario_walking2
	.WORD animation_loop

mario_skidding:
	.WORD mario_skidding0
	.WORD animation_loop

mario_jumping:
	.WORD mario_jumping0
	.WORD animation_loop

mario_swimming:
	.WORD mario_swimming0
	.WORD mario_swimming1
	.WORD mario_swimming2
	.WORD animation_loop

mario_climbing:
	.WORD mario_climbing0
	.WORD mario_climbing1
	.WORD animation_loop

mario_killed:
	.WORD mario_killed0
	.WORD animation_loop

goomba_stand:
	.WORD goomba_stand0
	.WORD goomba_stand1
	.WORD animation_loop

mario_standing0:
	.BYTE $04
	.BYTE $00, $00, $3A, $00
	.BYTE $00, $08, $37, $00
	.BYTE $08, $00, $4F, $00
	.BYTE $08, $08, $4F, $40

mario_walking0:
	.BYTE $04
	.BYTE $00, $00, $32, $00
	.BYTE $00, $08, $33, $00
	.BYTE $08, $00, $34, $00
	.BYTE $08, $08, $35, $00

mario_walking1:
	.BYTE $04
	.BYTE $00, $00, $36, $00
	.BYTE $00, $08, $37, $00
	.BYTE $08, $00, $38, $00
	.BYTE $08, $08, $39, $00

mario_walking2:
	.BYTE $04
	.BYTE $00, $00, $3A, $00
	.BYTE $00, $08, $37, $00
	.BYTE $08, $00, $3B, $00
	.BYTE $08, $08, $3C, $00

mario_skidding0:
	.BYTE $04
	.BYTE $00, $00, $3D, $00
	.BYTE $00, $08, $3E, $00
	.BYTE $08, $00, $3F, $00
	.BYTE $08, $08, $40, $00

mario_jumping0:
	.BYTE $04
	.BYTE $00, $00, $32, $00
	.BYTE $00, $08, $41, $00
	.BYTE $08, $00, $42, $00
	.BYTE $08, $08, $43, $00

mario_swimming0:
	.BYTE $04
	.BYTE $00, $00, $32, $00
	.BYTE $00, $08, $33, $00
	.BYTE $08, $00, $44, $00
	.BYTE $08, $08, $45, $00

mario_swimming1:
	.BYTE $04
	.BYTE $00, $00, $32, $00
	.BYTE $00, $08, $33, $00
	.BYTE $08, $00, $44, $00
	.BYTE $08, $08, $47, $00

mario_swimming2:
	.BYTE $04
	.BYTE $00, $00, $32, $00
	.BYTE $00, $08, $33, $00
	.BYTE $08, $00, $48, $00
	.BYTE $08, $08, $49, $00

mario_climbing0:
	.BYTE $04
	.BYTE $00, $00, $32, $00
	.BYTE $00, $08, $33, $00
	.BYTE $08, $00, $90, $00
	.BYTE $08, $08, $91, $00

mario_climbing1:
	.BYTE $04
	.BYTE $00, $00, $3A, $00
	.BYTE $00, $08, $37, $00
	.BYTE $08, $00, $92, $00
	.BYTE $08, $08, $93, $00

mario_killed0:
	.BYTE $04
	.BYTE $00, $00, $9E, $00
	.BYTE $00, $08, $9E, $40
	.BYTE $08, $00, $9F, $00
	.BYTE $08, $08, $9F, $40

goomba_stand0:
	.BYTE $04
	.BYTE $00, $00, $70, $00
	.BYTE $00, $08, $71, $00
	.BYTE $08, $00, $72, $00
	.BYTE $08, $08, $73, $00

goomba_stand1:
	.BYTE $04
	.BYTE $00, $00, $71, $40
	.BYTE $00, $08, $70, $40
	.BYTE $08, $00, $73, $40
	.BYTE $08, $08, $72, $40

animation_loop:
	.BYTE $FF, $00

setStanding:
	LDA #$00		; Set to Standing
	STA SPRITE_X_DELTA+0
	STA SPRITE_X_DELTA+1
	LDA #$00		; Set to Standing Animation
	STA SPRITE_ANIMATION
	STA SPRITE_FRAME_SUB	; Reset Frame
	STA SPRITE_FRAME
	RTS

setWalking:
	LDA #$01		; Set to Walk Animation
	STA SPRITE_ANIMATION
	LDA #$00		; Reset Frame
	STA SPRITE_FRAME_SUB
	STA SPRITE_FRAME
	RTS

setBraking:
	LDA #$02		; Set to Brake Animation
	STA SPRITE_ANIMATION
	LDA #$00		; Reset Frame
	STA SPRITE_FRAME_SUB
	STA SPRITE_FRAME
	RTS

animation:
	LDA SPRITE_ANIMATION	; Get Animation Pointer
	ASL
	TAX
	LDA animation_index+0,X
	STA TEMP+0
	LDA animation_index+1,X
	STA TEMP+1
@start:
	LDA SPRITE_FRAME	; Get Frame Pointer
	ASL
	TAY
	LDA (TEMP),Y
	STA ANIMATION+0
	INY
	LDA (TEMP),Y
	STA ANIMATION+1
	LDY #$00		; Set to Metasprite Size/Control Code
	LDA (ANIMATION),Y	; Get Metasprite Size/Control Code
	CMP #$FF		; Loop Control Code?
	BNE @noloop
	INY			; Set Loop Index
	LDA (ANIMATION),Y
	STA SPRITE_FRAME	; Set to Reset Frame
	JMP @start
@noloop:
	STA TEMP+2		; Store Metasprite Size
	LDX OAM_USED		; Get OAM Location
@load:
	INY			; Set Y Offset Index
	LDA (ANIMATION),Y	; Get Y Offset
	CLC
	ADC SPRITE_Y		; Y + Offset = Sprite Y
	STA __SPRITE_LOAD__+0,X	; Store Sprite Y
	INY			; X Offset Index
	BIT SPRITE_ATTRIBUTE	; Horizontal Flip?
	BVC @no_flip
	LDA SPRITE_X_LO		; X Location + Middle Spot = Right Edge
	CLC
	ADC #<$0008		; Middle Spot Lo
	STA TEMP+0
	LDA SPRITE_X_HI
	ADC #>$0008		; Middle Spot Hi
	STA TEMP+1
	LDA TEMP+0		; Right Edge - Offset = Sprite X
	SEC
	SBC (ANIMATION),Y
	STA TEMP+0
	LDA TEMP+1
	SBC #$00
	STA TEMP+1
	JMP @flipped
@no_flip:
	LDA (ANIMATION),Y	; Left Edge + Offset = Sprite X
	CLC
	ADC SPRITE_X_LO
	STA TEMP+0
	LDA #$00
	ADC SPRITE_X_HI
	STA TEMP+1
@flipped:
	LDA TEMP+0		; Sprite on Screen?
	SEC
	SBC XSCROLL+0
	STA TEMP+0
	LDA TEMP+1
	SBC XSCROLL+1
	STA TEMP+1
	BEQ @noskip
	LDA #$F0		; Set Sprite Off the Screen
	STA __SPRITE_LOAD__+0,X	; Store Sprite Y
	INY			; Skip Sprite Tile and Attribute
	INY
	JMP @done
@noskip:
	LDA TEMP+0		; Sprite X
	STA __SPRITE_LOAD__+3,X	; Store Sprite X
	INY			; Set Tile Index
	LDA (ANIMATION),Y	
	STA __SPRITE_LOAD__+1,X	; Store Sprite Tile
	INY			; Set Attribute Index
	LDA (ANIMATION),Y
	EOR SPRITE_ATTRIBUTE	; Set Horizontal Flip
	STA __SPRITE_LOAD__+2,X	; Store Sprite Attribute
	INX			; Next Sprite
	INX
	INX
	INX
@done:
	STX OAM_USED		; Store Used OAM
	DEC TEMP+2		; Last Sprite?
	BNE @load
@exit:
	RTS

clear_sprite:
	; Clear OAM Buffer
	LDY OAM_USED		; Set Index to First Byte
	BEQ @exit
	LDA #$F0		; Set Y Position to off-screen
:	STA __SPRITE_LOAD__,Y	; Store Y Position in OAM Buffer
	INY			; Set to next sprite
	INY
	INY
	INY
	BNE :-			; Last sprite?
@exit:
	RTS

setMario:
	LDA #$00		; SPRITE ANIMATION
	STA MARIO_DATA+0
	STA MARIO_DATA+1	; SPRITE FRAME SUB
	STA MARIO_DATA+2	; SPRITE FRAME
	LDA MARIO+0
	STA MARIO_DATA+3	; SPRITE Y
	LDA #$00
	STA MARIO_DATA+4	; SPRITE X SUB
	LDA MARIO+3
	STA MARIO_DATA+5	; SPRITE X LO
	LDA #$00
	STA MARIO_DATA+6	; SPRITE X HI
	STA MARIO_DATA+7	; SPRITE X DELTA + 0
	STA MARIO_DATA+8	; SPRITE X DELTA + 1
	LDA #$00
	STA MARIO_DATA+9	; SPRITE ATTRIBUTE
	LDA #$0F
	STA MARIO_DATA+10	; SPRITE HEIGHT
	RTS

setGoomba:
	LDA #$07		; SPRITE ANIMATION
	STA GOOMBA_DATA+0
	LDA #$00
	STA GOOMBA_DATA+1	; SPRITE FRAME SUB
	STA GOOMBA_DATA+2	; SPRITE FRAME
	LDA GOOMBA+0
	STA GOOMBA_DATA+3	; SPRITE Y
	LDA #$00
	STA GOOMBA_DATA+4	; SPRITE X SUB
	LDA GOOMBA+3
	STA GOOMBA_DATA+5	; SPRITE X LO
	LDA #$00
	STA GOOMBA_DATA+6	; SPRITE X HI
	STA GOOMBA_DATA+7	; SPRITE X DELTA + 0
	STA GOOMBA_DATA+8	; SPRITE X DELTA + 1
	LDA #$03
	STA GOOMBA_DATA+9	; SPRITE ATTRIBUTE
	LDA #$0F
	STA GOOMBA_DATA+10	; SPRITE HEIGHT
	RTS

datalocations:
	.WORD MARIO_DATA
	.WORD GOOMBA_DATA

loadData:
	TXA
	ASL
	TAY
	LDA datalocations+0,Y
	STA TEMP+0
	LDA datalocations+1,Y
	STA TEMP+1
	LDY #$00
	LDA (TEMP),Y
	STA SPRITE_ANIMATION
	INY
	LDA (TEMP),Y
	STA SPRITE_FRAME_SUB
	INY
	LDA (TEMP),Y
	STA SPRITE_FRAME
	INY
	LDA (TEMP),Y
	STA SPRITE_Y
	INY
	LDA (TEMP),Y
	STA SPRITE_X_SUB
	INY
	LDA (TEMP),Y
	STA SPRITE_X_LO
	INY
	LDA (TEMP),Y
	STA SPRITE_X_HI
	INY
	LDA (TEMP),Y
	STA SPRITE_X_DELTA+0
	INY
	LDA (TEMP),Y
	STA SPRITE_X_DELTA+1
	INY
	LDA (TEMP),Y
	STA SPRITE_ATTRIBUTE
	INY
	LDA (TEMP),Y
	STA SPRITE_HEIGHT
	RTS

storeData:
	TXA
	ASL
	TAY
	LDA datalocations+0,Y
	STA TEMP+0
	LDA datalocations+1,Y
	STA TEMP+1
	LDY #$00
	LDA SPRITE_ANIMATION
	STA (TEMP),Y
	INY
	LDA SPRITE_FRAME_SUB
	STA (TEMP),Y
	INY
	LDA SPRITE_FRAME
	STA (TEMP),Y
	INY
	LDA SPRITE_Y
	STA (TEMP),Y
	INY
	LDA SPRITE_X_SUB
	STA (TEMP),Y
	INY
	LDA SPRITE_X_LO
	STA (TEMP),Y
	INY
	LDA SPRITE_X_HI
	STA (TEMP),Y
	INY
	LDA SPRITE_X_DELTA+0
	STA (TEMP),Y
	INY
	LDA SPRITE_X_DELTA+1
	STA (TEMP),Y
	INY
	LDA SPRITE_ATTRIBUTE
	STA (TEMP),Y
	INY
	LDA SPRITE_HEIGHT
	STA (TEMP),Y
	RTS

;-------------------;
; COLLISION SECTION ;
;-------------------;

collision_check:
	LDX #$00		; Get Mario Sprite Data
	JSR loadData
	JSR x_sprite_collision	; Check for Collision
	LDX #$00		; Store Mario Sprite Data
	JSR storeData
	RTS

x_bg_collision:
	LDA SPRITE_Y		; Store Sprite Height Top Tile
	AND #%11111000
	STA TEMP+2
	LDA SPRITE_Y		; (Bottom Y - Top Y) / 8 + 1 = Tile Rows
	CLC
	ADC SPRITE_HEIGHT
	SEC
	SBC TEMP+2
	LSR
	LSR
	LSR
	STA TEMP+2
	INC TEMP+2	
	LDY SPRITE_Y		; Check for in Status Bar
@lower:
	CPY #$20		; Check for Sprites under Status Bar
	BCS @check
	DEC TEMP+2		; Last Tile?
	BEQ @exit
	LDA SPRITE_Y		; Set to Next Tile
	CLC
	ADC #$08
	TAY
	JMP @lower
@check:
	LDA SPRITE_X_DELTA+1	; Left or Right Direction?
	BPL @right
@left:
	JSR get_bg_tile_left	; Get Left Movement Source
	LDY #$00
@nextleft:
	LDA (SOURCE),Y		; Get Tile #
	CMP #$6A		; Solid Pipe Tile?
	BNE @emptyleft
	LDA SPRITE_X_LO
	AND #%11111000
	CLC
	ADC #<$0007
	STA SPRITE_X_LO
	LDA SPRITE_X_HI
	ADC #>$0007
	STA SPRITE_X_HI
	JMP @exit
@emptyleft:
	INY			; Set to Next Tile Down
	CPY TEMP+2		; Last Tile?
	BNE @nextleft
	JMP @exit
@right:
	JSR get_bg_tile_right	; Get Right Movement Source
	LDY #$00
@nextright:
	LDA (SOURCE),Y		; Get Tile #
	CMP #$68		; Solid Pipe Tile?
	BNE @emptyright
	LDA SPRITE_X_LO
	AND #%11111000
	STA SPRITE_X_LO
	JMP @exit
@emptyright:
	INY			; Set to Next Tile Down
	CPY TEMP+2		; Last Tile?
	BNE @nextright
@exit:
	RTS

get_bg_tile_left:
	; Get X Source Index
	LDA SPRITE_X_LO		; X / 8 = Column
	STA SOURCE+0
	LDA SPRITE_X_HI
	STA SOURCE+1
	JMP get_bg_tile
get_bg_tile_right:
	; Get X Source Index
	LDA SPRITE_X_LO		; X / 8 = Column
	CLC
	ADC #<$0010		; Sprite Width Lo
	STA SOURCE+0
	LDA SPRITE_X_HI
	ADC #>$0010		; Sprite Width Hi
	STA SOURCE+1
get_bg_tile:
	LSR SOURCE+1
	ROR SOURCE+0
	LSR SOURCE+1
	ROR SOURCE+0
	LSR SOURCE+1
	ROR SOURCE+0
	ASL SOURCE+0		; (Column * 32) - (Column * 6) = Source Index
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
	; Get X Source Address
	LDA SOURCE+0		; X Source Index + Source = X Source Address
	CLC
	ADC #<title_name_table
	STA SOURCE+0
	LDA SOURCE+1
	ADC #>title_name_table
	STA SOURCE+1
	; Get Y Source Index
	TYA			; Y / 8 = Row
	LSR
	LSR
	LSR
	SEC			; Row - Status Bar Rows = Y Source Index
	SBC #$04
	; Get Source Address
	CLC			; Y Source Index + X Source Address = Source Address
	ADC SOURCE+0
	STA SOURCE+0
	LDA #$00
	ADC SOURCE+1
	STA SOURCE+1
	RTS

x_sprite_collision:
	LDA #$01		; Get Sprite 2 Data Location
	ASL
	TAY
	LDA datalocations+0,Y
	STA TEMP+0
	LDA datalocations+1,Y
	STA TEMP+1
@y:				; Check Y Non-Collision
	LDY #$03		; Get Sprite 2 Y Data
	LDA (TEMP),Y
	STA ENEMY_Y		; Sprite 2 Y Lo
	; Compare Bounding Boxes of Sprite 1 and Sprite 2 Vertically
	LDA SPRITE_Y		; Sprite 1 Y location compared to Sprite 2 Y
	CMP ENEMY_Y
	BCS @bottom
@top:				; Check Sprite 1 Bot Y < Sprite 2 Top Y
	LDA ENEMY_Y
	SEC
	SBC SPRITE_Y
	CMP #$10		; Y Bounding Box Size of Sprite 1
	BCS @exit		; Possible Collision?
	JMP @x
@bottom:			; Check Sprite 1 Top Y > Sprite 2 Bot Y
	LDA SPRITE_Y
	SEC
	SBC ENEMY_Y
	CMP #$10		; Y Bounding Box Size of Sprite 2
	BCS @exit		; Possible Collision?
@x:				; Check for X Non-Collision
	LDY #$05		; Get Sprite 2 X Data
	LDA (TEMP),Y
	STA ENEMY_X_LO		; Sprite 2 X Lo
	INY
	LDA (TEMP),Y
	STA ENEMY_X_HI		; Sprite 2 X Hi
	; Compare Bounding Boxes of Sprite 1 and Sprite 2 Horizontally
	LDA SPRITE_X_LO		; Sprite 1 X Location compared to Sprite 2 X
	CMP ENEMY_X_LO
	LDA SPRITE_X_HI
	SBC ENEMY_X_HI
	BCS @right
@left:				; Check Sprite 1 Right X < Sprite 2 Left X
	LDA ENEMY_X_LO
	SEC
	SBC SPRITE_X_LO
	STA DISTANCE+0
	LDA ENEMY_X_HI
	SBC SPRITE_X_HI
	STA DISTANCE+1
	LDA DISTANCE+0
	CMP #<$0010		; X Bounding Box Lo Size of Sprite 1
	LDA DISTANCE+1
	SBC #>$0010		; X Bounding Box Hi Size of Sprite 1
	BCS @exit		; Collision?
	LDA #$00		; Stop Right Movement
	STA SPRITE_X_SUB
	LDA ENEMY_X_LO
	SEC
	SBC #<$0010		; Sprite 1 Width Lo
	STA SPRITE_X_LO
	LDA ENEMY_X_HI
	SBC #>$0010		; Sprite 1 Width Hi
	STA SPRITE_X_HI
	JMP @exit
@right:				; Check Sprite 1 Left X > Sprite 2 Right X
	LDA SPRITE_X_LO
	SEC
	SBC ENEMY_X_LO
	STA DISTANCE+0
	LDA SPRITE_X_HI
	SBC ENEMY_X_HI
	STA DISTANCE+1
	LDA DISTANCE+0
	CMP #<$0010		; X Bounding Box Lo Size of Sprite 2
	LDA DISTANCE+1
	SBC #>$0010		; X Bounding Box Hi Size of Sprite 2
	BCS @exit		; Collision?
	LDA #$00		; Stop Left Movement
	STA SPRITE_X_SUB
	LDA ENEMY_X_LO
	CLC
	ADC #<$0010		; Sprite 2 Width Lo
	STA SPRITE_X_LO
	LDA ENEMY_X_HI
	ADC #>$0010		; Sprite 2 Width Hi
	STA SPRITE_X_HI
@exit:
	RTS

;===============================================================================
.segment "BANK_01"
;=====================

;===============================================================================
.segment "VECTORS"
;=====================
	.WORD NMI, Reset, IRQ

;===============================================================================
.segment "GRAPHIC"
	.incbin "./resources/mario.chr"
