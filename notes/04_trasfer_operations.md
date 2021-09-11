# 6502 Opcodes - Transfer Operations

```text
 +-----------------------------------------------------------------+
 |                             MEMORY                              |
 |                           $0000-$FFFF                           |
 +-----------------------------------------------------------------+
      ^    |                   ^    |                   ^    |
      |    |                   |    |                   |    |
     STX  LDX                 STA  LDA                 STY  LDY
      |    |                   |    |                   |    |
      |    V                   |    V                   |    V
 +--------------+         +--------------+         +---------------+
 |              |---TXA-->|              |<--TYA---|               |
 |  X-REGISTER  |         |  A-REGISTER  |         |  Y-REGISTER   |
 |              |<--TAX---|              |---TAY-->|               |
 +--------------+         +--------------+         +---------------+
      |    ^                   ^    |
      |    |                   |    |
     TXS  TSX                 PLA  PHA
      |    |                   |    |
      V    |                   |    V
 +--------------+         +--------------+         +---------------+
 |              |         |              |---PLP-->|               |
 | SP-REGISTER  |         |    STACK     |         |  P-REGISTER   |
 |              |         | $0100-$01FF  |<--PHP---|   NV*BDIZC    |
 +--------------+         +--------------+         +---------------+
```

## Load Operations

```text
LDA = Set A to value
LDX = Set X to value
LDY = Set Y to value
```

## Store Operations

```text
STA = Store A in Location
STX = Store X in Location
STY = Store Y in Location
```

## Transfer Operations

```text
TAX = Set A in X
TXA = Set X in A
TAY = Set A in Y
TYA = Set Y in A
```

## Stack Operations

```text
TXS = Set X in Stack Pointer
TSX = Set Stack Pointer in X
PHA = Push A on Stack
PLA = Pull A from Stack
PHP = Push Processor Status on Stack
PLP = Pull Processor Status from Stack
```
