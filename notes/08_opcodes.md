# 6502 Opcodes

```text
ADC               Add Memory to Accumulator with Carry                ADC
Operation:  A = A + M + C                                     N Z C I D V
                                                              / / / _ _ /
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Immediate     |   ADC #Oper           |    69   |    2    |    2     |
|  Zero Page     |   ADC Oper            |    65   |    2    |    3     |
|  Zero Page,X   |   ADC Oper,X          |    75   |    2    |    4     |
|  Absolute      |   ADC Oper            |    6D   |    3    |    4     |
|  Absolute,X    |   ADC Oper,X          |    7D   |    3    |    4*    |
|  Absolute,Y    |   ADC Oper,Y          |    79   |    3    |    4*    |
|  (Indirect,X)  |   ADC (Oper,X)        |    61   |    2    |    6     |
|  (Indirect),Y  |   ADC (Oper),Y        |    71   |    2    |    5*    |
+----------------+-----------------------+---------+---------+----------+
* Add 1 if page boundary is crossed.

AND                Bitwise AND Memory with Accumulator                AND
Operation:  A &= M                                            N Z C I D V
                                                              / / _ _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Immediate     |   AND #Oper           |    29   |    2    |    2     |
|  Zero Page     |   AND Oper            |    25   |    2    |    3     |
|  Zero Page,X   |   AND Oper,X          |    35   |    2    |    4     |
|  Absolute      |   AND Oper            |    2D   |    3    |    4     |
|  Absolute,X    |   AND Oper,X          |    3D   |    3    |    4*    |
|  Absolute,Y    |   AND Oper,Y          |    39   |    3    |    4*    |
|  (Indirect,X)  |   AND (Oper,X)        |    21   |    2    |    6     |
|  (Indirect),Y  |   AND (Oper),Y        |    31   |    2    |    5*    |
+----------------+-----------------------+---------+---------+----------+
* Add 1 if page boundary is crossed.

ASL                    Arithmetic Shift Left By One                   ASL
                 +-+-+-+-+-+-+-+-+
Operation:  C <- |7|6|5|4|3|2|1|0| <- 0                       N Z C I D V
                 +-+-+-+-+-+-+-+-+                            / / / _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Accumulator   |   ASL A               |    0A   |    1    |    2     |
|  Zero Page     |   ASL Oper            |    06   |    2    |    5     |
|  Zero Page,X   |   ASL Oper,X          |    16   |    2    |    6     |
|  Absolute      |   ASL Oper            |    0E   |    3    |    6     |
|  Absolute,X    |   ASL Oper,X          |    1E   |    3    |    7     |
+----------------+-----------------------+---------+---------+----------+

BCC                      Branch on Carry Clear                        BCC
Operation:  Branch on C = 0                                   N Z C I D V
                                                              _ _ _ _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Relative      |   BCC Oper            |    90   |    2    |    2*    |
+----------------+-----------------------+---------+---------+----------+
* Add 1 if branch occurs to same page.
* Add 2 if branch occurs to different page.

BCS                       Branch on Carry Set                         BCS
Operation:  Branch on C = 1                                   N Z C I D V
                                                              _ _ _ _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Relative      |   BCS Oper            |    B0   |    2    |    2*    |
+----------------+-----------------------+---------+---------+----------+
* Add 1 if branch occurs to same page.
* Add 2 if branch occurs to next page.

BEQ                      Branch on Result Zero                        BEQ
Operation:  Branch on Z = 1                                   N Z C I D V
                                                              _ _ _ _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Relative      |   BEQ Oper            |    F0   |    2    |    2*    |
+----------------+-----------------------+---------+---------+----------+
* Add 1 if branch occurs to same  page.
* Add 2 if branch occurs to next  page.

BIT               Test Bits in Memory with Accumulator                BIT
Operation:  Z = A & M, N = M7, V = M6                         N Z C I D V
                                                              7 / _ _ _ 6
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Zero Page     |   BIT Oper            |    24   |    2    |    3     |
|  Absolute      |   BIT Oper            |    2C   |    3    |    4     |
+----------------+-----------------------+---------+---------+----------+

BMI                      Branch on Result Minus                       BMI
Operation:  Branch on N = 1                                   N Z C I D V
                                                              _ _ _ _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Relative      |   BMI Oper            |    30   |    2    |    2*    |
+----------------+-----------------------+---------+---------+----------+
* Add 1 if branch occurs to same page.
* Add 1 if branch occurs to different page.

BNE                    Branch on Result Not Zero                      BNE
Operation:  Branch on Z = 0                                   N Z C I D V
                                                              _ _ _ _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Relative      |   BNE Oper            |    D0   |    2    |    2*    |
+----------------+-----------------------+---------+---------+----------+
* Add 1 if branch occurs to same page.
* Add 2 if branch occurs to different page.

BPL                      Branch on Result Plus                        BPL
Operation:  Branch on N = 0                                   N Z C I D V
                                                              _ _ _ _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Relative      |   BPL Oper            |    10   |    2    |    2*    |
+----------------+-----------------------+---------+---------+----------+
* Add 1 if branch occurs to same page.
* Add 2 if branch occurs to different page.

BRK                            Force Break                            BRK
Operation:  S = PC + 2, S = P                                 N Z C I D V
                                                              _ _ _ 1 _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Implied       |   BRK                 |    00   |    1    |    7     |
+----------------+-----------------------+---------+---------+----------+
1. A BRK command cannot be masked by setting I.

BVC                     Branch on Overflow Clear                      BVC
Operation:  Branch on V = 0                                   N Z C I D V
                                                              _ _ _ _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Relative      |   BVC Oper            |    50   |    2    |    2*    |
+----------------+-----------------------+---------+---------+----------+
* Add 1 if branch occurs to same page.
* Add 2 if branch occurs to different page.

BVS                      Branch on Overflow Set                       BVS
Operation:  Branch on V = 1                                   N Z C I D V
                                                              _ _ _ _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Relative      |   BVS Oper            |    70   |    2    |    2*    |
+----------------+-----------------------+---------+---------+----------+
* Add 1 if branch occurs to same page.
* Add 2 if branch occurs to different page.

CLC                         Clear Carry Flag                          CLC
Operation:  C = 0                                             N Z C I D V
                                                              _ _ 0 _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Implied       |   CLC                 |    18   |    1    |    2     |
+----------------+-----------------------+---------+---------+----------+

CLD                        Clear Decimal Mode                         CLD
Operation:  D = 0                                             N A C I D V
                                                              _ _ _ _ 0 _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Implied       |   CLD                 |    D8   |    1    |    2     |
+----------------+-----------------------+---------+---------+----------+

CLI                   Clear Interrupt Disable Bit                     CLI
Operation:  I = 0                                             N Z C I D V
                                                              _ _ _ 0 _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Implied       |   CLI                 |    58   |    1    |    2     |
+----------------+-----------------------+---------+---------+----------+

CLV                       Clear Overflow Flag                         CLV
Operation:  V = 0                                             N Z C I D V
                                                              _ _ _ _ _ 0
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Implied       |   CLV                 |    B8   |    1    |    2     |
+----------------+-----------------------+---------+---------+----------+

CMP                  Compare Memory and Accumulator                   CMP
Operation:  A - M                                             N Z C I D V
                                                              / / / _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Immediate     |   CMP #Oper           |    C9   |    2    |    2     |
|  Zero Page     |   CMP Oper            |    C5   |    2    |    3     |
|  Zero Page,X   |   CMP Oper,X          |    D5   |    2    |    4     |
|  Absolute      |   CMP Oper            |    CD   |    3    |    4     |
|  Absolute,X    |   CMP Oper,X          |    DD   |    3    |    4*    |
|  Absolute,Y    |   CMP Oper,Y          |    D9   |    3    |    4*    |
|  (Indirect,X)  |   CMP (Oper,X)        |    C1   |    2    |    6     |
|  (Indirect),Y  |   CMP (Oper),Y        |    D1   |    2    |    5*    |
+----------------+-----------------------+---------+---------+----------+
* Add 1 if page boundary is crossed.

CPX                    Compare Memory and X Index                     CPX
Operation:  X - M                                             N Z C I D V
                                                              / / / _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Immediate     |   CPX #Oper           |    E0   |    2    |    2     |
|  Zero Page     |   CPX Oper            |    E4   |    2    |    3     |
|  Absolute      |   CPX Oper            |    EC   |    3    |    4     |
+----------------+-----------------------+---------+---------+----------+

CPY                    Compare Memory and Y Index                     CPY
Operation:  Y - M                                             N Z C I D V
                                                              / / / _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Immediate     |   CPY #Oper           |    C0   |    2    |    2     |
|  Zero Page     |   CPY Oper            |    C4   |    2    |    3     |
|  Absolute      |   CPY Oper            |    CC   |    3    |    4     |
+----------------+-----------------------+---------+---------+----------+

DEC                   Decrement Memory by One                         DEC
Operation:  M -= 1                                            N Z C I D V
                                                              / / _ _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Zero Page     |   DEC Oper            |    C6   |    2    |    5     |
|  Zero Page,X   |   DEC Oper,X          |    D6   |    2    |    6     |
|  Absolute      |   DEC Oper            |    CE   |    3    |    6     |
|  Absolute,X    |   DEC Oper,X          |    DE   |    3    |    7     |
+----------------+-----------------------+---------+---------+----------+

DEX                   Decrement X Index by One                    DEX
Operation:  X -= 1                                            N Z C I D V
                                                              / / _ _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Implied       |   DEX                 |    CA   |    1    |    2     |
+----------------+-----------------------+---------+---------+----------+

DEY                   Decrement Y Index by One                        DEY
Operation:  Y -= 1                                            N Z C I D V
                                                              / / _ _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Implied       |   DEY                 |    88   |    1    |    2     |
+----------------+-----------------------+---------+---------+----------+

EOR           Bitwise Exclusive OR Memory with Accumulator            EOR
Operation:  A ^= M                                            N Z C I D V
                                                              / / _ _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Immediate     |   EOR #Oper           |    49   |    2    |    2     |
|  Zero Page     |   EOR Oper            |    45   |    2    |    3     |
|  Zero Page,X   |   EOR Oper,X          |    55   |    2    |    4     |
|  Absolute      |   EOR Oper            |    4D   |    3    |    4     |
|  Absolute,X    |   EOR Oper,X          |    5D   |    3    |    4*    |
|  Absolute,Y    |   EOR Oper,Y          |    59   |    3    |    4*    |
|  (Indirect,X)  |   EOR (Oper,X)        |    41   |    2    |    6     |
|  (Indirect),Y  |   EOR (Oper),Y        |    51   |    2    |    5*    |
+----------------+-----------------------+---------+---------+----------+
* Add 1 if page boundary is crossed.

INC                     Increment Memory by One                       INC
Operation:  M += 1                                            N Z C I D V
                                                              / / _ _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Zero Page     |   INC Oper            |    E6   |    2    |    5     |
|  Zero Page,X   |   INC Oper,X          |    F6   |    2    |    6     |
|  Absolute      |   INC Oper            |    EE   |    3    |    6     |
|  Absolute,X    |   INC Oper,X          |    FE   |    3    |    7     |
+----------------+-----------------------+---------+---------+----------+

INX                     Increment X Index by One                      INX
Operation:  X += 1                                            N Z C I D V
                                                              / / _ _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Implied       |   INX                 |    E8   |    1    |    2     |
+----------------+-----------------------+---------+---------+----------+

INY                     Increment Y Index by One                      INY
Operation:  Y += 1                                            N Z C I D V
                                                              / / _ _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Implied       |   INY                 |    C8   |    1    |    2     |
+----------------+-----------------------+---------+---------+----------+

JMP                       Jump to New Location                        JMP
Operation:  PCL = PC + 1, PCH = PC + 2                        N Z C I D V
                                                              _ _ _ _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Absolute      |   JMP Oper            |    4C   |    3    |    3     |
|  Indirect      |   JMP (Oper)          |    6C   |    3    |    5     |
+----------------+-----------------------+---------+---------+----------+

JSR                        Jump to Subroutine                         JSR
Operation:  S = PC + 2, PCL = PC + 1, PCH = PC + 2            N Z C I D V
                                                              _ _ _ _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Absolute      |   JSR Oper            |    20   |    3    |    6     |
+----------------+-----------------------+---------+---------+----------+

LDA                   Load Accumulator with Memory                    LDA
Operation:  A = M                                             N Z C I D V
                                                              / / _ _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Immediate     |   LDA #Oper           |    A9   |    2    |    2     |
|  Zero Page     |   LDA Oper            |    A5   |    2    |    3     |
|  Zero Page,X   |   LDA Oper,X          |    B5   |    2    |    4     |
|  Absolute      |   LDA Oper            |    AD   |    3    |    4     |
|  Absolute,X    |   LDA Oper,X          |    BD   |    3    |    4*    |
|  Absolute,Y    |   LDA Oper,Y          |    B9   |    3    |    4*    |
|  (Indirect,X)  |   LDA (Oper,X)        |    A1   |    2    |    6     |
|  (Indirect),Y  |   LDA (Oper),Y        |    B1   |    2    |    5*    |
+----------------+-----------------------+---------+---------+----------+
* Add 1 if page boundary is crossed.

LDX                     Load X Index with Memory                      LDX
Operation:  X = M                                             N Z C I D V
                                                              / / _ _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Immediate     |   LDX #Oper           |    A2   |    2    |    2     |
|  Zero Page     |   LDX Oper            |    A6   |    2    |    3     |
|  Zero Page,Y   |   LDX Oper,Y          |    B6   |    2    |    4     |
|  Absolute      |   LDX Oper            |    AE   |    3    |    4     |
|  Absolute,Y    |   LDX Oper,Y          |    BE   |    3    |    4*    |
+----------------+-----------------------+---------+---------+----------+
* Add 1 when page boundary is crossed.

LDY                     Load Y Index with Memory                      LDY
Operation:  Y = M                                             N Z C I D V
                                                              / / _ _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Immediate     |   LDY #Oper           |    A0   |    2    |    2     |
|  Zero Page     |   LDY Oper            |    A4   |    2    |    3     |
|  Zero Page,X   |   LDY Oper,X          |    B4   |    2    |    4     |
|  Absolute      |   LDY Oper            |    AC   |    3    |    4     |
|  Absolute,X    |   LDY Oper,X          |    BC   |    3    |    4*    |
+----------------+-----------------------+---------+---------+----------+
* Add 1 when page boundary is crossed.

LSR                   Logical Shift Right One Bit                     LSR
                 +-+-+-+-+-+-+-+-+
Operation:  0 -> |7|6|5|4|3|2|1|0| -> C                       N Z C I D V
                 +-+-+-+-+-+-+-+-+                            0 / / _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Accumulator   |   LSR A               |    4A   |    1    |    2     |
|  Zero Page     |   LSR Oper            |    46   |    2    |    5     |
|  Zero Page,X   |   LSR Oper,X          |    56   |    2    |    6     |
|  Absolute      |   LSR Oper            |    4E   |    3    |    6     |
|  Absolute,X    |   LSR Oper,X          |    5E   |    3    |    7     |
+----------------+-----------------------+---------+---------+----------+

NOP                           No Operation                            NOP
Operation:  No Operation                                      N Z C I D V
                                                              _ _ _ _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Implied       |   NOP                 |    EA   |    1    |    2     |
+----------------+-----------------------+---------+---------+----------+

ORA                Bitwise OR Memory with Accumulator                 ORA
Operation:  A |= M                                            N Z C I D V
                                                              / / _ _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Immediate     |   ORA #Oper           |    09   |    2    |    2     |
|  Zero Page     |   ORA Oper            |    05   |    2    |    3     |
|  Zero Page,X   |   ORA Oper,X          |    15   |    2    |    4     |
|  Absolute      |   ORA Oper            |    0D   |    3    |    4     |
|  Absolute,X    |   ORA Oper,X          |    1D   |    3    |    4*    |
|  Absolute,Y    |   ORA Oper,Y          |    19   |    3    |    4*    |
|  (Indirect,X)  |   ORA (Oper,X)        |    01   |    2    |    6     |
|  (Indirect),Y  |   ORA (Oper),Y        |    11   |    2    |    5*    |
+----------------+-----------------------+---------+---------+----------+
* Add 1 on page crossing

PHA                    Push Accumulator on Stack                      PHA
Operation:  S = A                                             N Z C I D V
                                                              _ _ _ _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Implied       |   PHA                 |    48   |    1    |    3     |
+----------------+-----------------------+---------+---------+----------+

PHP                 Push Processor Status on Stack                    PHP
Operation:  S = P                                             N Z C I D V
                                                              _ _ _ _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Implied       |   PHP                 |    08   |    1    |    3     |
+----------------+-----------------------+---------+---------+----------+

PLA                  Pull Accumulator from Stack                      PLA
Operation:  A = S                                             N Z C I D V
                                                              _ _ _ _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Implied       |   PLA                 |    68   |    1    |    4     |
+----------------+-----------------------+---------+---------+----------+

PLP                 Pull Processor Status from Stack                  PLA
Operation:  P = S                                             N Z C I D V
                                                              / / / / / /
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Implied       |   PLP                 |    28   |    1    |    4     |
+----------------+-----------------------+---------+---------+----------+

ROL                       Rotate One Bit Left                         ROL
             +------------------------------+
             |   +-+-+-+-+-+-+-+-+    +-+   |
Operation:   +-< |7|6|5|4|3|2|1|0| <- |C| <-+                 N Z C I D V
                 +-+-+-+-+-+-+-+-+    +-+                     / / / _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Accumulator   |   ROL A               |    2A   |    1    |    2     |
|  Zero Page     |   ROL Oper            |    26   |    2    |    5     |
|  Zero Page,X   |   ROL Oper,X          |    36   |    2    |    6     |
|  Absolute      |   ROL Oper            |    2E   |    3    |    6     |
|  Absolute,X    |   ROL Oper,X          |    3E   |    3    |    7     |
+----------------+-----------------------+---------+---------+----------+

ROR                       Rotate One Bit Right                        ROR
             +------------------------------+
             |   +-+    +-+-+-+-+-+-+-+-+   |
Operation:   +-> |C| -> |7|6|5|4|3|2|1|0| >-+                 N Z C I D V
                 +-+    +-+-+-+-+-+-+-+-+                     / / / _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Accumulator   |   ROR A               |    6A   |    1    |    2     |
|  Zero Page     |   ROR Oper            |    66   |    2    |    5     |
|  Zero Page,X   |   ROR Oper,X          |    76   |    2    |    6     |
|  Absolute      |   ROR Oper            |    6E   |    3    |    6     |
|  Absolute,X    |   ROR Oper,X          |    7E   |    3    |    7     |
+----------------+-----------------------+---------+---------+----------+

RTI                      Return from Interrupt                        RTI
Operation:  P = S, PC = S                                     N Z C I D V
                                                              / / / / / /
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Implied       |   RTI                 |    40   |    1    |    6     |
+----------------+-----------------------+---------+---------+----------+

RTS                      Return from Subroutine                       RTS
Operation:  PC = S + 1                                        N Z C I D V
                                                              _ _ _ _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Implied       |   RTS                 |    60   |    1    |    6     |
+----------------+-----------------------+---------+---------+----------+

SBC           Subtract Memory from Accumulator with Borrow            SBC
Operation:  A = A - M - ~C                                    N Z C I D V
                                                              / / / _ _ /
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Immediate     |   SBC #Oper           |    E9   |    2    |    2     |
|  Zero Page     |   SBC Oper            |    E5   |    2    |    3     |
|  Zero Page,X   |   SBC Oper,X          |    F5   |    2    |    4     |
|  Absolute      |   SBC Oper            |    ED   |    3    |    4     |
|  Absolute,X    |   SBC Oper,X          |    FD   |    3    |    4*    |
|  Absolute,Y    |   SBC Oper,Y          |    F9   |    3    |    4*    |
|  (Indirect,X)  |   SBC (Oper,X)        |    E1   |    2    |    6     |
|  (Indirect),Y  |   SBC (Oper),Y        |    F1   |    2    |    5     |
+----------------+-----------------------+---------+---------+----------+
* Add 1 when page boundary is crossed.

SEC                          Set Carry Flag                           SEC
Operation:  C = 1                                             N Z C I D V
                                                              _ _ 1 _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Implied       |   SEC                 |    38   |    1    |    2     |
+----------------+-----------------------+---------+---------+----------+

SED                         Set Decimal Mode                          SED
Operation:  D = 1                                             N Z C I D V
                                                              _ _ _ _ 1 _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Implied       |   SED                 |    F8   |    1    |    2     |
+----------------+-----------------------+---------+---------+----------+

SEI                   Set Interrupt Disable Status                    SEI
Operation:  I = 1                                             N Z C I D V
                                                              _ _ _ 1 _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Implied       |   SEI                 |    78   |    1    |    2     |
+----------------+-----------------------+---------+---------+----------+

STA                   Store Accumulator in Memory                     STA
Operation:  M = A                                             N Z C I D V
                                                              _ _ _ _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Zero Page     |   STA Oper            |    85   |    2    |    3     |
|  Zero Page,X   |   STA Oper,X          |    95   |    2    |    4     |
|  Absolute      |   STA Oper            |    80   |    3    |    4     |
|  Absolute,X    |   STA Oper,X          |    90   |    3    |    5     |
|  Absolute,Y    |   STA Oper,Y          |    99   |    3    |    5     |
|  (Indirect,X)  |   STA (Oper,X)        |    81   |    2    |    6     |
|  (Indirect),Y  |   STA (Oper),Y        |    91   |    2    |    6     |
+----------------+-----------------------+---------+---------+----------+

STX                     Store X Index in Memory                       STX
Operation:  M = X                                             N Z C I D V
                                                              _ _ _ _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Zero Page     |   STX Oper            |    86   |    2    |    3     |
|  Zero Page,Y   |   STX Oper,Y          |    96   |    2    |    4     |
|  Absolute      |   STX Oper            |    8E   |    3    |    4     |
+----------------+-----------------------+---------+---------+----------+

STY                     Store Y Index in Memory                       STY
Operation:  M = Y                                             N Z C I D V
                                                              _ _ _ _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Zero Page     |   STY Oper            |    84   |    2    |    3     |
|  Zero Page,X   |   STY Oper,X          |    94   |    2    |    4     |
|  Absolute      |   STY Oper            |    8C   |    3    |    4     |
+----------------+-----------------------+---------+---------+----------+

TAX                 Transfer Accumulator to X Index                   TAX
Operation:  X = A                                             N Z C I D V
                                                              / / _ _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Implied       |   TAX                 |    AA   |    1    |    2     |
+----------------+-----------------------+---------+---------+----------+

TAY                 Transfer Accumulator to Y Index                   TAY
Operation:  Y = A                                             N Z C I D V
                                                              / / _ _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Implied       |   TAY                 |    A8   |    1    |    2     |
+----------------+-----------------------+---------+---------+----------+

TSX                Transfer Stack Pointer to X Index                  TSX
Operation:  X = SP                                            N Z C I D V
                                                              / / _ _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Implied       |   TSX                 |    BA   |    1    |    2     |
+----------------+-----------------------+---------+---------+----------+

TXA                 Transfer X Index to Accumulator                   TXA
Operation:  A = X                                             N Z C I D V
                                                              / / _ _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Implied       |   TXA                 |    8A   |    1    |    2     |
+----------------+-----------------------+---------+---------+----------+

TXS                Transfer X Index to Stack Pointer                  TXS
Operation:  SP = X                                            N Z C I D V
                                                              _ _ _ _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Implied       |   TXS                 |    9A   |    1    |    2     |
+----------------+-----------------------+---------+---------+----------+

TYA                 Transfer Y Index to Accumulator                   TYA
Operation:  A = Y                                             N Z C I D V
                                                              / / _ _ _ _
+----------------+-----------------------+---------+---------+----------+
| Addressing Mode| Assembly Language Form| OP CODE |No. Bytes|No. Cycles|
+----------------+-----------------------+---------+---------+----------+
|  Implied       |   TYA                 |    98   |    1    |    2     |
+----------------+-----------------------+---------+---------+----------+
```