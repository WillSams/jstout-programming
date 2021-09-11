# Animated Sprites

To animate a sprite, we need to change the sprite tile over a period of time to produce what looks like a moving object (the same principle as a flipbook drawing).  Each change of the sprite image is called a frame.

The Game Loop should set the sprite or metasprite (multiple sprites set near each other to form what looks like one bigger object) to update, update the changes, and then move to the next sprite or metasprite.  After we calculate the sprite and scrolling changes, we need to write the new sprite to the OAM Buffer.  If the amount of sprites used is variable then we should also clear the OAM Buffer before writing the new sprite data into the OAM Buffer.

```lisp
animation:
	LDA SPRITE_ANIMATION	; Get Animation Pointer
	ASL
	TAX
	LDA animation_index+0,X
	STA TEMP+0
	LDA animation_index+1,X
	STA TEMP+1
@start:
	LDA SPRITE_FRAME		; Get Frame Pointer
	ASL
	TAY
	LDA (TEMP),Y
	STA ANIMATION+0
	INY
	LDA (TEMP),Y
	STA ANIMATION+1
	LDY #$00			; Set to Metasprite Size/Control Code
	LDA (ANIMATION),Y		; Get Metasprite Size/Control Code
	CMP #$FF			; Loop Control Code?
	BNE @noloop
	INY				; Set Loop Index
	LDA (ANIMATION),Y
	STA SPRITE_FRAME		; Set to Reset Frame
	JMP @start
@noloop:
	STA TEMP+2			; Store Metasprite Size
	LDX OAM_USED		; Get OAM Location
@load:
	INY				; Set Y Offset Index
	LDA (ANIMATION),Y		; Get Y Offset
	CLC
	ADC SPRITE_Y		; Y + Offset = Sprite Y
	STA SPRITE+0,X		; Store Sprite Y
	INY				; X Offset Index
	BIT SPRITE_ATTRIBUTE	; Horizontal Flip?
	BVC @no_flip
	LDA SPRITE_X_LO		; X Location + Middle Spot = Right Edge
	CLC
	ADC #<$0008			; Middle Spot Lo
	STA TEMP+0
	LDA SPRITE_X_HI
	ADC #>$0008			; Middle Spot Hi
	STA TEMP+1
	LDA TEMP+0			; Right Edge - Offset = Sprite X
	SEC
	SBC (ANIMATION),Y
	STA TEMP+0
	LDA TEMP+1
	SBC #$00
	STA TEMP+1
	JMP @flipped
@no_flip:
	LDA (ANIMATION),Y		; Left Edge + Offset = Sprite X
	CLC
	ADC SPRITE_X_LO
	STA TEMP+0
	LDA #$00
	ADC SPRITE_X_HI
	STA TEMP+1
@flipped:
	LDA TEMP+0			; Sprite on Screen?
	SEC
	SBC XSCROLL+0
	STA TEMP+0
	LDA TEMP+1
	SBC XSCROLL+1
	STA TEMP+1
	BEQ @noskip
	LDA #$F0			; Set Sprite Off the Screen
	STA SPRITE+0,X		; Store Sprite Y
	INY				; Skip Sprite Tile and Attribute
	INY
	JMP @done
@noskip:
	LDA TEMP+0			; Sprite X
	STA SPRITE+3,X		; Store Sprite X
	INY				; Set Tile Index
	LDA (ANIMATION),Y	
	STA SPRITE+1,X		; Store Sprite Tile
	INY				; Set Attribute Index
	LDA (ANIMATION),Y
	EOR SPRITE_ATTRIBUTE	; Set Horizontal Flip
	STA SPRITE+2,X		; Store Sprite Attribute
	INX				; Next Sprite
	INX
	INX
	INX
@done:
	STX OAM_USED		; Store Used OAM
	DEC TEMP+2			; Last Sprite?
	BNE @load
@exit:
	RTS

animation_index:			; Animation Pointers
	.WORD mario_standing	; $00 Standing
	.WORD mario_walking	; $01 Walking
	.WORD mario_skidding	; $02 Braking

mario_standing:			; Standing Frame Pointer
	.WORD mario_standing0
	.WORD animation_loop

mario_walking:			; Walking Frame Pointer
	.WORD mario_walking0
	.WORD mario_walking1
	.WORD mario_walking2
	.WORD animation_loop

mario_skidding:			; Skidding Frame Pointer
	.WORD mario_skidding0
	.WORD animation_loop

; Frame Format
; # of Sprites in Metasprite
; Y Offset, X Offset, Tile #, Attribute

mario_standing0:			; Standing Frame 0
	.BYTE $04
	.BYTE $00, $00, $3A, $00
	.BYTE $00, $08, $37, $00
	.BYTE $08, $00, $4F, $00
	.BYTE $08, $08, $4F, $40

mario_walking0:			; Walking Frame 0
	.BYTE $04
	.BYTE $00, $00, $32, $00
	.BYTE $00, $08, $33, $00
	.BYTE $08, $00, $34, $00
	.BYTE $08, $08, $35, $00

mario_walking1:			; Walking Frame 1
	.BYTE $04
	.BYTE $00, $00, $36, $00
	.BYTE $00, $08, $37, $00
	.BYTE $08, $00, $38, $00
	.BYTE $08, $08, $39, $00

mario_walking2:			; Walking Frame 2
	.BYTE $04
	.BYTE $00, $00, $3A, $00
	.BYTE $00, $08, $37, $00
	.BYTE $08, $00, $3B, $00
	.BYTE $08, $08, $3C, $00

mario_skidding0:			; Skidding Frame 0
	.BYTE $04
	.BYTE $00, $00, $3D, $00
	.BYTE $00, $08, $3E, $00
	.BYTE $08, $00, $3F, $00
	.BYTE $08, $08, $40, $00

animation_loop:			; Loop to Frame 0
	.BYTE $FF, $00
```

Because we must track many variables for each sprite or metasprite like location, animation, frame, speed, object type, and etc., we will need to use RAM to hold the relevant data.  Each sprite/metasprite or data type should have its own area that can be accessed by an index or a subroutine that can load the data to specific RAM locations or one of the A,X,Y registers.
