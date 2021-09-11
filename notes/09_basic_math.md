# 6502 Basic Math

## Addition:  VALUE_A + VALUE_B = RESULT

### 8-bit with 8-bit Result

```lisp
	LDA VALUE_A+0
	CLC
	ADC VALUE_B+0
	STA RESULT+0
```

### 8-bit with 16-bit Result

```lisp
	LDA VALUE_A+0
	CLC
	ADC VALUE_B+0
	STA RESULT+0
	LDA #$00
	ADC #$00
	STA RESULT+1
```

### 16-bit with 16-bit Result

```lisp
	LDA VALUE_A+0
	CLC
	ADC VALUE_B+0
	STA RESULT+0
	LDA VALUE_A+1
	ADC VALUE_B+1
	STA RESULT+1
```

### 16-bit with 24-bit Result

```lisp
	LDA VALUE_A+0
	CLC
	ADC VALUE_B+0
	STA RESULT+0
	LDA VALUE_A+1
	ADC VALUE_B+1
	STA RESULT+1
	LDA #$00
	ADC #$00
	STA RESULT+2
```

## Subtraction:  VALUE_A - VALUE_B = RESULT

### 8-bit with 8-bit Result

```lisp
	LDA VALUE_A+0
	SEC
	SBC VALUE_B+0
	STA RESULT+0
```

### 16-bit with 16-bit Result

```lisp
	LDA VALUE_A+0
	SEC
	SBC VALUE_B+0
	STA RESULT+0
	LDA VALUE_A+1
	SBC VALUE_B+1
	STA RESULT+1
```

## Multiplication (Unsigned):  VALUE_A * VALUE_B = RESULT

### 8-bit with 8-bit Result

```lisp
	LDA #$00
	STA RESULT+0
	LDX #$08
@loop:
	ASL RESULT+0
	ASL VALUE_A+0
	BCC @next
	LDA VALUE_B+0
	CLC
	ADC RESULT+0
	STA RESULT+0
@next:
	DEX
	BNE @loop
```

*Note: VALUE_A is destroyed in the process

### 8-bit with 16-bit Result

```lisp
	LDA #$00
	STA RESULT+0
	STA RESULT+1
	LDX #$08
@loop:
	ASL RESULT+0
	ROL RESULT+1
	ASL VALUE_A+0
	BCC @next
	LDA VALUE_B+0
	CLC
	ADC RESULT+0
	STA RESULT+0
	LDA #$00
	ADC RESULT+1
	STA RESULT+1
@next:
	DEX
	BNE @loop
```

*Note: VALUE_A is destroyed in the process

### 16-bit with 16-bit Result

```lisp
	LDA #$00
	STA RESULT+0
	STA RESULT+1
	LDX #$10
@loop:
	ASL RESULT+0
	ROL RESULT+1
	ASL VALUE_A+0
	ROL VALUE_A+1
	BCC @next
	LDA VALUE_B+0
	CLC
	ADC RESULT+0
	STA RESULT+0
	LDA VALUE_B+1
	ADC RESULT+1
	STA RESULT+1
@next:
	DEX
	BNE @loop
*Note: VALUE_A is destroyed in the process
```

### 16-bit with 32-bit Result

```lisp
	LDA #$00
	STA RESULT+0
	STA RESULT+1
	STA RESULT+2
	STA RESULT+3
	LDX #$10
@loop:
	ASL RESULT+0
	ROL RESULT+1
	ROL RESULT+2
	ROL RESULT+3
	ASL VALUE_A+0
	ROL VALUE_A+1
	BCC @next
	LDA VALUE_B+0
	CLC
	ADC RESULT+0
	STA RESULT+0
	LDA VALUE_B+1
	ADC RESULT+1
	STA RESULT+1
	LDA #$00
ADC RESULT+2
STA RESULT+2
LDA #$00
ADC RESULT+3
STA RESULT+3
@next:
	DEX
	BNE @loop
```

*Note: VALUE_A is destroyed in the process

## Division (Unsigned):  VALUE_A / VALUE_B = RESULT and REMAINDER

### 8-bit with 8-bit Result and Remainder

```lisp
	LDA #$00
	STA REMAINDER+0
	LDX #$08
@loop:
	ASL VALUE_A+0
	ROL REMAINDER+0
	LDA REMAINDER+0
	SEC
	SBC VALUE_B+0
	BCC @next
	STA REMAINDER+0
@next:
	ROL RESULT+0
	DEX
	BNE @loop
```

*Note: VALUE_A is destroyed in the process

### 16-bit with 16-bit Result and Remainder

```lisp
	LDA #$00
	STA REMAINDER+0
	STA REMAINDER+1
	LDX #$10
@loop:
	ASL VALUE_A+0
	ROL VALUE_A+1
	ROL REMAINDER+0
	ROL REMAINDER+1
	LDA REMAINDER+0
	SEC
	SBC VALUE_B+0
	TAY
	LDA REMAINDER+1
	SBC VALUE_B+1
	BCC @next
	STA REMAINDER+1
	STY REMAINDER+0
@next:
	ROL RESULT+0
	ROL RESULT+1
	DEX
	BNE @loop
```

*Note: VALUE_A is destroyed in the process

## Arithmetic Shift Left = Multiply by 2

### 8-bit with 8-bit Result

```lisp
ASL VALUE_A+0
```

### 8-bit with 16-bit Result

```lisp
	LDA #$00
	STA VALUE_A+1
	ASL VALUE_A+0
	ROL VALUE_A+1
```

### 16-bit with 16-bit Result

```lisp
	ASL VALUE_A+0
	ROL VALUE_A+1
```

### 16-bit with 24-bit Result

```lisp
	LDA #$00
	STA VALUE_A+2
	ASL VALUE_A+0
	ROL VALUE_A+1
	ROL VALUE_A+2
```

## Logical Shift Right = Divide by 2

## 8-bit with 8-bit Result

```lisp
	LDA #$00
	STA REMAINDER+0
	LSR VALUE_A+0
	ROL REMAINDER+0
```

## 16-bit with 16-bit Result

```lisp
	LDA #$00
	STA REMAINDER+0
	ROR VALUE_A+1
	LSR VALUE_A+0
	ROL REMAINDER+0
```

## Negate (Signed):  VALUE_A * -1 = RESULT

#### 8-bit with 8-bit Result

```lisp
LDA #$00
SEC
SBC VALUE_A+0
STA RESULT+0
```

### 16-bit with 16-bit Result

```lisp
LDA #$00
SEC
SBC VALUE_A+0
STA RESULT+0
LDA #$00
SBC VALUE_A+1
STA RESULT+1
Increment: ; VALUE_A + 1 = VALUE_A
```

### 8-bit with 8-bit Result

```lisp
INC VALUE_A+0
```

### 16-bit with 16-bit Result

```lisp
	INC VALUE_A+0
	BNE @done
	INC VALUE_A+1
@done:
```

## Decrement:  VALUE_A - 1 = VALUE_A

### 8-bit with 8-bit Result

```lisp
DEC VALUE_A+0
```

### 16-bit with 16-bit Result

```lisp
	LDA VALUE_A+0
	BNE @done
	DEC VALUE_A+1
@done:
	DEC VALUE_A+0
```

## Comparison

### 8-bit Unsigned

```lisp
	LDA VALUE_A+0
	CMP VALUE_B+0
```

### 16-bit Unsigned

```lisp
LDA VALUE_A+0
CMP VALUE_B+0
LDA VALUE_A+1
SBC VALUE_B+1
```

### 8-bit Signed

```lisp
	LDA VALUE_A+0
	CMP VALUE_B+0
	BEQ @done
LDA VALUE_A+0
SEC
SBC VALUE_B+0
BVC @done
EOR #$80
@done:
```

### 16-bit Signed

```lisp
LDA VALUE_A+0
CMP VALUE_B+0
BNE @notequal
LDA VALUE_A+1
SBC VALUE_B+1
BVS @overflow
JMP @done
@notequal:
LDA VALUE_A+1
SBC VALUE_B+1
ORA #$01
BVC @done
@overflow:
EOR #$80
ORA #$01
@done:
```

## Fixed Point

Fixed Point is one way to store fractions where the lo byte is a fractional value.  An 8-bit whole number with an 8-bit fraction now is treated as a 16-bit value using normal 16-bit math operations for calculations.

```text
%76543210.76543210
 |||||||| ||||||||
 |||||||| |||||||+- 2^-8 = 1/256
 |||||||| ||||||+-- 2^-7 = 1/128 or 2/256
 |||||||| |||||+--- 2^-6 = 1/64  or 4/256
 |||||||| ||||+---- 2^-5 = 1/32  or 8/256
 |||||||| |||+----- 2^-4 = 1/16  or 16/256
 |||||||| ||+------ 2^-3 = 1/8   or 32/256
 |||||||| |+------- 2^-2 = 1/4   or 64/256
 |||||||| +-------- 2^-1 = 1/2   or 128/256
 |||||||+---------- 2^0  = 1
 ||||||+----------- 2^1  = 2
 |||||+------------ 2^2  = 4
 ||||+------------- 2^3  = 8
 |||+-------------- 2^4  = 16
 ||+--------------- 2^5  = 32
 |+---------------- 2^6  = 64
 +----------------- 2^7  = 128
````

To write 5 2/3 in fixed point:

```text
5 = 4 + 1 = %00000101
2/3 * 256 = 512/3 = 170 = 128 + 32 + 8 + 2 = %10101010
%00000101.10101010 or $05.AA
```
