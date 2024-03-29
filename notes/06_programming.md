# 6502 Opcodes - Programming mode

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

## Other Operations

```text
 +-----------------------------------------------------------------+
 | A-REGISTER    X-REGISTER    Y-REGISTER    MEMORY           |
 | ---------------------------------------------------------- |
 | Arithmetic:  ADC           INX           INY           INC |
 | SBC           DEX           DEY           DEC              |
 |                                                            |
 | Logical:     AND           ---           ---           BIT |
 | ORA           ---           ---           ---              |
 | EOR           ---           ---           ---              |
 |                                                            |
 | Shift:       ASL           ---           ---           ASL |
 | LSR           ---           ---           LSR              |
 | ROL           ---           ---           ROL              |
 | ROR           ---           ---           ROR              |
 |                                                            |
 | Compare:     CMP           CPX           CPY           --- |
 +-----------------------------------------------------------------+

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

    Jump:     JMP, JSR   -------------------------------------------
                         6502 Programming Model, Bob Sander-Cederlof
    Return:   RTS, RTI          Apple Assembly Line, May 1981
                         http://txbobsc.com/aal/1981/aal8105.html#a4
    Other:    NOP, BRK   -------------------------------------------
```