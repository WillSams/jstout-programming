# NES Memory Map

## CPU (Central Processing Unit)

The NES uses an 8-bit microprocessor based on a MOS Technology 6502 core that incorporates a custom sound hardware, restricted DMA controller on-die, and an omitted BCD (binary coded decimal) mode to avoid patent payments.  The NTSC (North America, Japan, and Korea) version is a Ricoh 2A03 (RP2A03) running at 1.79 MHz and the PAL (Europe, Australia, and South Asia) version is a Ricoh 2A07 (RP2A07) running at 1.66 MHz.  The CPU contains 2 KiB (2048 bytes) of onboard work RAM while cartridges can load up to 32 KiB (32768 bytes) of program ROM and almost 16 KiB (16352 bytes) of Expansion Area which often contain 8 KiB (8192 bytes) of save RAM (SRAM).

## CPU Memory Map

```text
+-------------+-------------+--------------------------------+
| Work RAM    | $0000-$00FF | Zero Page RAM                  |
|             | $0100-$01FF | Stack Memory                   |
|             | $0200-$07FF | RAM                            |
|             | $0800-$0FFF | Mirror of $0000-$07FF          |
|             | $1000-$17FF | Mirror of $0000-$07FF          |
|             | $1800-$1FFF | Mirror of $0000-$07FF          |
+-------------+-------------+--------------------------------+
| I/O Ports   | $2000-$2007 | PPU Registers                  |
|             | $2008-$3FFF | Mirrors of $2000-$2007         |
|             | $4000-$401F | APU and Input/Output Registers |
+-------------+-------------+--------------------------------+
| Expansion   | $4020-$5FFF | Expansion ROM or RAM           |
|             | $6000-$7FFF | Save RAM                       |
+-------------+-------------+--------------------------------+
| Program ROM | $8000-$BFFF | Lower Bank                     |
|             | $C000-$FFF9 | Upper Bank                     |
|             | $FFFA-$FFFB | NMI Vector                     |
|             | $FFFC-$FFFD | Reset Vector                   |
|             | $FFFE-$FFFF | IRQ/BRK Vector                 |
+-------------+-------------+--------------------------------+
```

## PPU (Picture Processing Unit)

The NES uses a custom-made PPU by Ricoh.  The NTSC version is a Ricoh 2C02 (RP2C02) running at 5.37 MHz and the PAL version is a Ricoh 2C07 (RP2C07) running at 5.32 MHz.  The PPU contains 2 KiB (2048 bytes) of video RAM (VRAM), 256 bytes of on-die OAM (object attribute memory) for sprites, and 28 bytes of on-die palette RAM while cartridges can load 8 KiB (8192 bytes) of tile pattern ROM or RAM.  The PPU may only be accessed during the vertical retrace phase.  The PPU allows for one scrolling layer though horizontal scroll can be changed on a per-scanline basis for a parallax effect and the vertical scroll can be changed between scanlines for a split-screen effect.  Each scanline can only display 8 sprites.  The standard display resolution is 256 horizontal x 240 vertical pixels but NTSC-based systems only display 256 x 224 pixels.  Each 16x16 pixel square must use the same palette.  

## PPU Memory Map

```text
+--------------+-------------+------------------------+
| Tile Pattern | $0000-$0FFF | Tile Pattern Table 0   |
| ROM or RAM   | $1000-$1FFF | Tile Pattern Table 1   |
+--------------+-------------+------------------------+
| Video RAM    | $2000-$23BF | Name Table 0           |
|              | $23C0-$23FF | Attribute Table 0      |
|              | $2400-$27BF | Name Table 1           |
|              | $27C0-$27FF | Attribute Table 1      |
|              | $2800-$2BBF | Name Table 2           |
|              | $2BC0-$2BFF | Attribute Table 2      |
|              | $2C00-$2FBF | Name Table 3           |
|              | $2FC0-$2FFF | Attribute Table 3      |
|              | $3000-$3EFF | Mirror of $2000-$2EFF  |
+--------------+-------------+------------------------+
| Palette RAM  | $3F00-$3F0F | Background Palette     |
|              | $3F10-$3F1F | Sprite Palette         |
|              | $3F20-$3FFF | Mirrors of $3F00-$3F1F |
+--------------+-------------+------------------------+
```

## OAM

```text
+-----+-------------+-------------------+
| OAM | $0000-$00FF | Sprite Attributes |
+-----+-------------+-------------------+
```
