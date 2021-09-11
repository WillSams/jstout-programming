# Sprites

- Sprites are objects that are independent of the background.  Sprites can be rendered anywhere on the screen however the NES can only display 64 sprites at once and will only display 8 sprites per scanline.  Sprites are stored in OAM.
- The $2000 Register sets sprites as either 8x8 or 8x16 pixels in size and the tile pattern to be used for 8x8 sprites.
- The $2001 Register sets whether sprites are to be displayed on screen and whether to display in the left column of the screen.
- The $2003 Register sets the address in OAM to write to and the $2004 Register writes the data to the OAM.
- The $4014 Register is the OAM DMA (Direct Memory Access) and is used in place of the $2004 Register.  The $4014 Register writes an entire memory page to the OAM.

## Example

```lisp
LDA #$02; Memory Page 2 * $100 = RAM Address $200
STA $4014; OAM DMA will copy $200-$2FF in RAM into OAM
```

## Sprite Attributes

Each sprite is made up of 4 bytes.

```text
Byte 1 = Y Position
#$00 = Top to #$EE = Bottom, #$EF-#$FF set the sprite off the screen.

Byte 2 = Tile Index Number
For 8x8 Sprites: Tile Number
For 8x16 Sprites: %76543210
                   ||||||||
                   |||||||+- Tile Pattern (0 = $0000, 1 = $1000)
                   +++++++-- Tile Number of Top (Bottom is next tile)

Byte 3 = Attributes
%76543210
 ||||||||
 ||||||++- Palette (00 = Palette 0, 01 = Palette 1, 10 = Palette 2, 11 = Palette 3
 |||+++--- Unimplemented
 ||+------ Priority (0 = In front of BG, 1 = Behind BG)
 |+------- Flip Horizontally (0 = No Flip, 1 = Flip)
 +-------- Flip Vertically (0 = No Flip, 1 = Flip)

Byte 4 = X Position
#$00 = Left to #$FF = Right
```

## Reset

In the reset routine we need to set all the sprites off the screen and write the sprites for the initial screen.

```lisp
load_title_sprites:
  LDX #<title_sprites    ;Source Lo Byte
  LDY #>title_sprites    ;Source Hi Byte
  LDA #.LOBYTE(title_sprites_end - title_sprites)  ;Source Length
  JSR load_oam
  RTS

load_oam:
  STX TEMP+0      ; Store Source Lo Byte
  STY TEMP+1      ; Store Source Hi Byte
  STA TEMP+2      ; Store Source Length
; Clear OAM Buffer
  LDY #$00
  LDA #$F0      ; Set Y Position to off-screen
:STA SPRITE,Y   ; Store Y Position in OAM Buffer
  INY           ; Set to next sprite
  INY
  INY
  INY
  BNE :-          ; Last sprite?
; Load Sprites into OAM Buffer
: LDA (TEMP),Y    ; Get Sprite Attribute
  STA SPRITE,Y    ; Store in OAM Buffer
  INY             ; Next Sprite Attribute
  CPY TEMP+2      ; Last Sprite Attribute?
  BNE :-
  RTS

title_sprites:
  .BYTE $3C,$01,%00000000,$20 ; Square Sprite
  .BYTE $74,$02,%00000001,$7C ; Circle Sprite
  .BYTE $B0,$03,%00000010,$D8 ; Triangle Sprite
title_sprites_end:
```

## Game Loop

In the Game Loop, we want to calculate all the sprite changes and store them in the OAM Buffer.

## NMI

In the NMI, we want to update the OAM with our OAM Buffer.

```lisp
update_oam:
  LDA #$00      ; Set to first byte in OAM
  STA $2003
  LDA #>SPRITE  ; Set to the OAM Buffer Memory Page  
  STA $4014     ; DMA OAM Buffer to OAM
  RTS
```
