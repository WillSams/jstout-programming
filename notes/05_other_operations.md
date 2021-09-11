# 6502 Opcodes - Other Operations

```text
 +-----------------------------------------------------------------+
 | A-REGISTER    X-REGISTER    Y-REGISTER    MEMORY           |
 | ---------------------------------------------------------- |
 | Arithmetic:  ADC           INX           INY           INC |
 | SBC           DEX           DEY           DEC              |
 | Logical:     AND           ---           ---           BIT |
 | ORA           ---           ---           ---              |
 | EOR           ---           ---           ---              |
 | Shift:       ASL           ---           ---           ASL |
 | LSR           ---           ---           LSR              |
 | ROL           ---           ---           ROL              |
 | ROR           ---           ---           ROR              |
 | Compare:     CMP           CPX           CPY           --- |
 +-----------------------------------------------------------------+
```

## Arithmetic Operations

```text
ADC = Add with Carry         A = Accumulator + Value + C Flag
SBC = Subtract with Carry    A = Accumulator – Value - ~C Flag
```

## Increment and Decrement Operations

```text
INX = Increase X             X = X + 1
INY = Increase Y             Y = Y + 1
INC = Increase Memory        Value = Value + 1
DEX = Decrease X             X = X – 1
DEY = Decrease Y             Y = Y – 1
DEC = Decrease Memory        Value = Value – 1
```

## Logical Operations

```text
AND = Bitwise AND            A = A & Value
ORA = Bitwise OR             A = A | Value
EOR = Bitwise XOR            A = A ^ Value
BIT = Bit Test               A & Value and copy Value bit 7 to N and bit 6 to V

Bit   | 0 | 1 |
------+---+---+
AND 0 | 0 | 0 |              AND results with 1 when both bits are 1
AND 1 | 0 | 1 |
ORA 0 | 0 | 1 |              OR results with 1 when at least one bit is 1
ORA 1 | 1 | 1 |
EOR 0 | 0 | 1 |              EOR results with 1 when only one bit is 1
EOR 1 | 1 | 0 |
------+---+---+
```

## Shift Operations

```text
ASL = Arithmetic Shift Left  Value = Value << 1
LSR = Logical Shift Right    Value = Value >> 1
ROL = Rotate Left            Value = Value << and bit 0 = C
ROR = Rotate Right           Value = Value >> 1 and bit 7 = C
```

## Compare Operations

```text
CMP = Compare to A           Accumulator - Value
CPX = Compare to X           X Index - Value
CPY = Compare to Y           Y Index – Value
 +----------------------------------------------------+
 | Status:      SET           CLEAR         BRANCH  |
 | ------------------------------------------------ |
 | CARRY   SEC           CLC           BCC, BCS     |
 | OVERFLOW   ---           CLV           BVC, BVS  |
 | DECIMAL   SED           CLD           --------   |
 | INTERRUPT   SEI           CLI           -------- |
 | ZERO   ---           ---           BNE, BEQ      |
 | MINUS   ---           ---           BPL, BMI     |
 +----------------------------------------------------+
```

## Status Flag Operations

```text
SEC = Set Carry Flag
SED = Set Decimal Mode
SEI = Set Interrupt Disable Flag
CLC = Clear Carry Flag
CLV = Clear Overflow Flag
CLD = Clear Decimal Mode
CLI = Clear Interrupt Disable Flag
```

## Branch Operations

```text
BCC = Branch if Carry Flag Clear
BVC = Branch if Overflow Flag Clear
BNE = Branch if Zero Flag Clear
BPL = Branch if Negative Flag Clear
BCS = Branch if Carry Flag Set
BVS = Branch if Overflow Flag Set
BEQ = Branch if Zero Flag Set
BMI = Branch if Negative Flag Set

Branch Instructions for Compares          | Unsigned  |  Signed   |
------------------------------------------+-----------+-----------+
Register is less than data                | BCC THERE | BMI THERE |
------------------------------------------+-----------+-----------+
Register is equal to data                 | BEQ THERE | BEQ THERE |
------------------------------------------+-----------+-----------+
Register is greater than data             | BEQ HERE  | BEQ HERE  |
                                          | BCS THERE | BPL THERE |
------------------------------------------+-----------+-----------+
Register is less than or equal to data    | BCC THERE | BMI THERE |
                                          | BEQ THERE | BEQ THERE |
------------------------------------------+-----------+-----------+
Register is greater than or equal to data | BCS THERE | BPL THERE |
------------------------------------------+-----------+-----------+
*Note: THERE Branches and HERE goes to continuation of code after the second branch.
```

## Jump & Call Operations

```text
JMP = Jump to Location
JSR = Jump to Subroutine
RTS = Return from Subroutine
```

## System Operations

```text
RTI = Return from Interrupt
NOP = No Operation
BRK = Force Interrupt
```
