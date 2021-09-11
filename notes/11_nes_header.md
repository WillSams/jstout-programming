# NES Header

The NES header tells an emulator about the cartridge setup for proper emulation purposes.

Byte 1-4: $4E, $45, $53, $1A (“NES” followed by MS-DOS end-of-file)
Byte 5: Size of Program ROM in 16 KB units
Byte 6: Size of Character ROM in 8 KB units (0 = Character RAM)
Byte 7: Cartridge Type LSB
Byte 8: Cartridge Type MSB
Byte 9: Size of Program RAM in 8 KB units (0 = 8 KB for compatibility)
Byte 10: TV System (few emulators honor this)
Byte 11: Unofficial Flag (few emulators honor this)
Byte 12-16: Zero Filled

## Cartridge Type LSB

```text
%76543210
 ||||||||
 |||||||+- Mirroring (0 = Horizontal, 1 = Vertical)
 ||||||+-- Battery-backed SRAM in CPU $6000-$7FFF (0 = No, 1 = Yes)
 |||||+--- 512-byte trainer at $7000-$71FF (0 = No, 1 = Yes)
 ||||+---- Four-screen VRAM Layout (0 = No, 1 = Yes)
 ++++----- Lower Nibble of ROM Mapper Number
```

## Cartridge Type MSB

```text
%76543210
 ||||||||
 |||||||+- VS. UniSystem Game (0 = No, 1 = Yes)
 ||||||+-- PlayChoice-10 Game (0 = No, 1 = Yes)
 ||||++--- NES 2.0 Format (00 = No, 10 = Yes)
 ++++----- Upper Nibble of ROM Mapper Number
```

## TV System

```text
%76543210
 |||||||+- TV System (0 = NTSC, 1 = PAL)
 +++++++-- Reserved (Set to 0)
```

## Unofficial Flag

```text
%76543210
   ||  ||
   ||  ++- TV System (00 = NTSC, 01 or 11 = Dual Compatible, 10 = PAL)
   |+----- SRAM in CPU $6000-$7FFF (0 = Yes, 1 = No)
   +------ Bus Conflicts (0 = No, 1 = Yes)
```