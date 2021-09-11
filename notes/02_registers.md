# 6502 Registers

## Accumulator Register (A)

The accumulator stores bytes to and from the CPU's arithmetic logic unit and is the main purpose register.  The accumulator holds only one byte.

## X Index Register (X)

The X index is used to find offsets from a location in memory, as a general purpose register, to hold a byte temporarily, and to communicate with the stack pointer.  The X index holds only one byte.

## Y Index Register (Y)

The Y index is used to find offsets from a location in memory, as a general purpose register, and to hold a byte temporarily.  The Y index holds only one byte.

## Processor Status Register (P)

The processor status contains eight bits to record flag conditions.  The processor status is only one byte.

## Stack Pointer Register (SP)

The stack pointer stores the address of the next free byte on the stack (special area in RAM where the CPU stores data).  The stack pointer is only one byte.

## Program Counter Register (PC)

The program counter holds the next byte to be fetched from memory.  The program counter is 2 bytes (16-bit).