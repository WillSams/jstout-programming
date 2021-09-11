# 6502 Processor Status Flags

## Carry Flag (C)

The carry flag is set if the result of the last operation caused an overflow from bit 7 or an underflow from bit 0.

Addition: Result of $00-$FF = Clear and > $FF (Overflow) = Set
Subtraction: Result of $00-$FF (Underflow) = Set and < $00 = Clear

## Zero Flag (Z)

The zero flag is set if the result of the last operation was zero.

Interrupt Disable Flag (I):

The interrupt disable flag is set by the SEI instruction and cleared by the CLI instruction.

## Decimal Mode (D)

The NES has no decimal mode.

## Break Command (B)

The break command is set when a BRK instruction has been executed and an interrupt has been generated to process it.

## Overflow Flag (V)

The overflow flag is set when an arithmetic operation results in an invalid signed result.  This occurs when adding and a positive result is negative or subtracting and a negative result is positive.

## Negative Flag (N)

The negative flag is set if the result of the last operation had bit 7 set to 1.