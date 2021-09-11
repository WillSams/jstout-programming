# 6502 Addressing Modes

## Immediate Addressing

Immediate Addressing is a 2-byte instruction.  The first byte contains the opcode specifying the operation and address mode.  The second byte contains a constant value known to the programmer.

LDA #$02.  The value of 2 is loaded into A.

## Absolute Addressing

Absolute Addressing is a 3-byte instruction.  The first byte contains the opcode specifying the operation and address mode.  The second byte contains the lo byte of an effective address.  The third byte contains the hi byte of an effective address.

LDA $0200.  The value located at $0200 is loaded into A.

## Zero Page Addressing

Zero Page Addressing is a 2-byte instruction.  The first byte contains the opcode specifying the operation and address mode.  The second byte contains an effective address in page zero of memory ($0000-$00FF).

LDA $B0.  The value located at $B0 is loaded into A.

## Implied Addressing

Implied Addressing is a 1-byte instruction.  The byte contains the opcode specifying the operation.

CLC.  Clear the Carry Flag.

## Indirect Addressing

Indirect Addressing is a 3-byte instruction.  The first byte contains the opcode specifying the operation and address mode.  The second byte contains the lo byte of a pointed address.  The third byte contains the hi byte of a pointed address.

JMP ($8000).  $8000 contains the lo byte and $8001 contains the hi byte.  If $8000 = #$03 and $8001 = #$A0.  The program counter will be set to the $A003 address.

## Relative Addressing

Relative Address is a 2-byte instruction.  The first byte contains the opcode specifying the operation and address mode.  The second byte contains the number of signed bytes to offset from the current address.

If A = 0, BEQ $03.  The program counter will be moved 3 bytes after the BEQ $03.

## Accumulator Addressing

Accumulator Addressing is a 1-byte instruction.  The byte contains the opcode specifying the operation to be performed on the A register.

If A = 1, ASL.  A will be shifted left and will become the value 2.

## Absolute,X Addressing

Absolute Addressing is a 3-byte instruction.  The first byte contains the opcode specifying the operation and address mode.  The second byte contains the lo byte of a base address.  The third byte contains the hi byte of a base address.  The base address will be offset by X.  Base Address + X

If X = 6, LDA $0200,X.  The value located at $0206 is loaded into A.

## Absolute,Y Addressing

Absolute Addressing is a 3-byte instruction.  The first byte contains the opcode specifying the operation and address mode.  The second byte contains the lo byte of a base address.  The third byte contains the hi byte of a base address.  The base address will be offset by Y. Base Address + Y

If Y = 6, LDA $0200,Y.  The value located at $0206 is loaded into A.

## Zero Page,X Addressing

Zero Page Addressing is a 2-byte instruction.  The first byte contains the opcode specifying the operation and address mode.  The second byte contains a base address in page zero of memory ($0000-$00FF) offset by X.  Base Address + X

If X = 6, LDA $B0,X.  The value located at $B6 is loaded into A.

## Zero Page,Y Addressing

Zero Page Addressing is a 2-byte instruction.  The first byte contains the opcode specifying the operation and address mode.  The second byte contains a base address in page zero of memory ($0000-$00FF) offset by Y.  Base Address + Y

If Y = 6, LDX $B0,Y.  The value located at $B6 is loaded into X.

## (Indirect,X) Addressing

Indirect Addressing is a 2-byte instruction.  The first byte contains the opcode specifying the operation and address mode.  The second byte contains the lo byte of a pointed address in page zero of memory ($0000-$00FF) offset by X.  The hi byte of the pointed address is the next byte in page zero of memory ($0000-$00FF).

If X = 6, LDA ($B0,X).  $B6 contains the lo byte and $B7 contains the hi byte.  If $B6 = #$00 and $B7 = #$80.  The value located at $8000 is loaded into A.

## (Indirect),Y Addressing

Indirect Addressing is a 2-byte instruction.  The first byte contains the opcode specifying the operation and address mode.  The second byte contains the lo byte of a pointed address in page zero of memory ($0000-$00FF).  The hi byte of the pointed address is the next byte in page zero of memory ($0000-$00FF).  The pointed address is offset by Y.

If Y = 6, LDA ($B0),Y.  $B0 contains the lo byte and $B1 contains the hi byte.  If $B0 = #$00 and $B1 = #$80.  The value located at $8006 is loaded into A.
