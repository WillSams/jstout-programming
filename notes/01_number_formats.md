# 6502 Number Formats

## Hexadecimal

Our normal number format is Decimal which is a base 10 system while Hexadecimal is a base 16 system. Below is a decimal to hexadecimal chart.  The symbol $ (or sometimes x) before a number means hexadecimal format.

```text
0  = $0
1  = $1
2  = $2
3  = $3
4  = $4
5  = $5
6  = $6
7  = $7
8  = $8
9  = $9
10 = $A
11 = $B
12 = $C
13 = $D
14 = $E
15 = $F
16 = $10
```

Any base system can be calculated to decimal by (Base^Digit)*Decimal_Number.  Below is an example of a decimal and hexadecimal calculation.

## Decimal

```text
; Example:                   Decimal: 254
  (10^0)*n                   (10^0)*4 = 1*4   =   4
+ (10^1)*n                 + (10^1)*5 = 10*5  =  50
+ (10^2)*n                 + (10^2)*2 = 100*2 = 200
                           ========================
                                                254

Hexadecimal:

; Example:                   Hexadecimal: $FE
  (16^0)*n                   (16^0)*14 = 1*14  =  14
+ (16^1)*n                 + (16^1)*15 = 16*15 = 240
                           =========================
                                                 254
```

## Word

A word is represented by 4 hexadecimal digits.  Example: $F21A is a word.

## Byte

A byte is represented by 2 hexadecimal digits.  Example: $1A is a byte.

In a word, the hi byte is the first 2 digits and the lo byte is the last 2 digits.  Example: $F21A, $F2 is the hi byte and $1A is the lo byte.

## Nibble (or Nybble)

A nibble is represented by 1 hexadecimal digit. Example: $B is a nibble.

## Bits

A bit can only be a 0 or 1. 4 bits make a nibble, 8 bits makes a byte, and 16 bits makes a word.  The symbol % before a number means bit format.

```text
%00000000 = $00 (Decimal 0)
%00000001 = $01 (Decimal 1)
%00000010 = $02 (Decimal 2)
%00000100 = $04 (Decimal 4)
%00001000 = $08 (Decimal 8)
%00010000 = $10 (Decimal 16)
%00100000 = $20 (Decimal 32)
%01000000 = $40 (Decimal 64)
%10000000 = $80 (Decimal 128)
```

To make $0A in bits:

```text
 %00001000 = $08 (Decimal 8)
+%00000010 = $02 (Decimal 2)
============================
 %00001010 = $0A (Decimal 10)
```

## Unsigned and Signed Hexadecimal

Unsigned means the number range is always positive and signed means the number range contains negative numbers.

In unsigned hexadecimal, $00-$FF is Decimal 0 to 255.

In signed hexadecimal, $80-$FF is Decimal -128 to -1 and $00-$7F is Decimal 0 to 127.
