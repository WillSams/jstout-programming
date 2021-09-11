# Controllers

The standard NES controller has a directional pad with Select, Start, A, and B buttons.

## Strobing

Strobing allows the NES to load the current state of the buttons into a shift register then disabling the reloading of the shift register so we can read the state of the buttons.  We do this by writing 1 then 0 to $4016 (this strobes both controller 1 and 2).

```lisp
   LDA #$01   ; Reload Shift Register
  STA $4016
   LDA #$00   ; Disable Reload Shift Register
  STA $4016
```

## Output

We read the state of the buttons by reading $4016 for controller 1 and $4017 for controller 2.  Each read will get the state of a button with the 0 bit set as 0 not pressed or 1 pressed:

```text
%76543210
 ||||||||
 |||||||+- Serial Controller Data
 ||||||+-- Famicon Expansion Port Data
 |||+++--- Always 0
 +++------ Open Bus
 ```

First Read:   A Button
Second Read:  B Button
Third Read:   Select Button
Fourth Read:  Start Button
Fifth Read:   Up Button
Sixth Read:   Down Button
Seventh Read: Left Button
Eighth Read:  Right Button

## DMC Glitch

When the APU (Audio Processing Unit) runs a DMC DMA cycle at the same time as a controller read the shift register will drop a bit.  To be safe many commercial games read the controller until two consecutive reads match.

## Game Loop/NMI

The controller reads should be updated in either the game loop or in NMI.  In the game loop guarantees the same buttons exist for all checks but reads occur less often.  In the NMI guarantees consistent reading but buttons may change during checks in the game loop.  

```lisp
update_joypad:
   ; Joypad Strobing
   LDA #$01
  STA $4016   ; Set Strobe
   LDA #$00
  STA $4016   ; Clear Strobe
   ; Read Joypad 1
  LDX JOYRAW1   ; Previous Joypad 1 Read
  LDY #$08   ; Set to read 8 buttons
:   LDA $4016   ; Get Joypad 1 Button
   LSR           ; Set Button in Carry
  ROL JOYRAW1   ; Set Button in Raw Data
  AND #%00000001   ; Famicon Expansion Port 3 Button
  ORA JOYRAW1   ; Set Famicon Button in Raw Data
  STA JOYRAW1   ; Store Raw Data
  DEY           ; Next Button
  BNE :-   ; Last Button?
   ; Pressed Button Check
  TXA           ; Previous Joypad Read
  EOR JOYRAW1   ; Find Button Changes
  AND JOYRAW1   ; Find New Button Changes
  STA JOYPRESS1   ; Store Pressed Buttons
   ; Held Button Check
  TXA           ; Previous Joypad Read
  AND JOYRAW1   ; Find Same Buttons
  STA JOYHELD1   ; Store Held Buttons
   ; Read Joypad 2
  LDX JOYRAW2   ; Previous Joypad 2 Read
  LDY #$08   ; Set to read 8 buttons
:   LDA $4017   ; Get Joypad 2 Button
   LSR           ; Set Button in Carry
  ROL JOYRAW2   ; Set Button in Raw Data
  AND #%00000001   ; Famicon Expansion Port 4 Button
  ORA JOYRAW2   ; Set Famicon Button in Raw Data
  STA JOYRAW2   ; Store Raw Data
  DEY           ; Next Button
  BNE :-   ; Last Button?
   ; Pressed Button Check
  TXA           ; Previous Joypad Read
 EOR JOYRAW2    ; Find Button Changes
  AND JOYRAW2   ; Find New Button Changes
  STA JOYPRESS2   ; Store Pressed Buttons
   ; Held Button Check
  TXA    ; Previous Joypad Read
  AND JOYRAW2   ; Find Same Buttons
  STA JOYHELD2   ; Store Held Buttons
  RTS

update_joypad_safe:
   LDA #$04
  STA JOYCHECK   ; Store Check Amount
  LDX JOYRAW1   ; Previous Joypad 1 Read
  TXA
@check1:
  STA JOYCONFIRM   ; Store Confirmation Data
   ; Joypad Strobing
   LDA #$01
  STA $4016   ; Set Strobe
   LDA #$00
  STA $4016   ; Clear Strobe
   ; Read Joypad 1
  LDY #$08   ; Set to read 8 buttons
@loop1:
   LDA $4016   ; Get Joypad 1 Button
   LSR     ; Set Button in Carry
  ROL JOYRAW   ; Set Button in Raw Data
  AND #%00000001   ; Famicon Expansion Port 3 Button
  ORA JOYRAW   ; Set Button in Raw Data
  STA JOYRAW   ; Store Raw Data
  DEY    ; Next Button
  BNE @loop1   ; Last Button?
  CMP JOYCONFIRM   ; Same Read?
  BEQ @store1
  DEC JOYCHECK   ; Last Check?
  BNE @check1
  JMP @next   ; No Matches
@store1:
  STA JOYRAW1   ; Store Joypad 1 Raw Data
   ; Pressed Button Check
  TXA   ; Previous Joypad Read
  EOR JOYRAW1   ; Find Button Changes
  AND JOYRAW1   ; Find New Button Changes
  STA JOYPRESS1   ; Store Pressed Buttons
   ; Held Button Check
  TXA   ; Previous Joypad Read
  AND JOYRAW1   ; Find Same Buttons
  STA JOYHELD1   ; Store Held Buttons
@next:
   LDA #$04
  STA JOYCHECK   ; Store Check Amount
  LDX JOYRAW2   ; Previous Joypad 2 Read
  TXA
@check2:
  STA JOYCONFIRM   ; Store Confirmation Data
   ; Joypad Strobing
   LDA #$01
  STA $4016   ; Set Strobe
   LDA #$00
  STA $4016   ; Clear Strobe
   ; Read Joypad 2
  LDY #$08   ; Set to read 8 buttons
@loop2:
   LDA $4017   ; Get Joypad 2 Button
   LSR         ; Set Button in Carry
  ROL JOYRAW   ; Set Button in Raw Data
  AND #%00000001   ; Famicon Expansion Port 4 Button
  ORA JOYRAW   ; Set Button in Raw Data
  STA JOYRAW   ; Store Raw Data
  DEY   ; Next Button
  BNE @loop2   ; Last Button?
  LDA JOYRAW   ; Same Read?
  CMP JOYCONFIRM
  BEQ @store2
  DEC JOYCHECK   ; Last Check?
  BNE @check2
  JMP @exit   ; No Matches
@store2:
  STA JOYRAW2   ; Store Joypad 2 Raw Data
   ; Pressed Button Check
  TXA   ; Previous Joypad Read
  EOR JOYRAW2   ; Find Button Changes
  AND JOYRAW2   ; Find New Button Changes
  STA JOYPRESS2 ; Store Pressed Buttons
   ; Held Button Check
  TXA   ; Previous Joypad Read
  AND JOYRAW2   ; Find Same Buttons
  STA JOYHELD2   ; Store Held Buttons
@exit:
  RTS
```