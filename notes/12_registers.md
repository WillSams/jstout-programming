# PPU REGISTERS

The PPU Registers allow the CPU and the PPU to communicate.

## PPU Control and Status Registers:

$2000 [Write] = PPU Control Register 1

```text
%76543210
 ||||||||
 ||||||++- Name Base Address (00 = $2000, 01 = $2400, 10 = $2800, 11 = $2C00)
 |||||+--- VRAM Address Increment (0 = 1 [Across], 1 = 32 [Down])
 ||||+---- Object Base Address in 8x8 Mode (0 = $0000, 1 = $1000)
 |||+----- Background Base Address (0 = $0000, 1 = $1000)
 ||+------ Object Size Select (0 = 8x8, 1 = 8x16)
 |+------- Master/Slave Mode Select (Always Set to 0)
 +-------- NMI Enable (0 = Disabled, 1 = Enabled)
```

When NMIs are enabled an NMI is generated 60 times a second on a NTSC version and 50 times a second on a PAL version at the start of each Vertical Blank (VBlank) allowing us to access and update VRAM.

$2001 [Write] = PPU Control Register 2

```text
%76543210
 ||||||||
 |||||||+- Color Mode Select (0: Color, 1: Monochrome)
 ||||||+-- Background Clipping (0: Hide, 1: Show)
 |||||+--- Object Clipping (0: Hide, 1: Show)
 ||||+---- Background Enable (0: Disable, 1: Enable)
 |||+----- Object Enable (0: Disable, 1: Enable)
 ||+------ Red Brightness (0: Disable, 1: Enable)
 |+------- Green Brightness (0: Disable, 1: Enable)
 +-------- Blue Brightness (0: Disable, 1: Enable)
```

If both Object and Background are disabled then video output is disabled (Forced Blank) and VRAM can be accessed at any time however OAM will stop receiving refresh cycles and its contents will gradually degrade.

$2002 [Read] = PPU Status Register

```text
%76543210
 |||
 ||+------ Object Overflow (0: False, 1: True)
 |+------- Object 0 Hit (0: False, 1: True)
 +-------- Vertical Blank Period Flag (0: Out of VBlank, 1: In VBlank)
```

When Read, bit 7 Clears and Resets VRAM Address Latch

## PPU OAM Access Registers:

$2003 [Write] = OAM Address Register

$2003 specifies the destination address in OAM for $2004 and $4014 and is usually only set to #$00.  The register is used internally during rendering.

$2004 [Read/Write] = OAM Data Register

$2004 writes data to OAM at the current OAM Address.  Writes to $2004 will auto increase the address in $2003 by 1 but reads are not incremented.
$2004 is not regularly used in commercial NES games.  Instead games will use $4014 to DMA transfer to OAM as it is faster and causes less potential glitches.

## PPU VRAM Access Registers:

$2005 [Write x2] = Scroll Offset Register

First Write = Horizontal Scroll Offset
Second Write = Vertical Scroll Offset

$2006 [Write x2] = VRAM Address Register

First Write = VRAM Address Hi
Second Write = VRAM Address Lo

$2007 [Read/Write] = VRAM Data Register

$2007 writes data to VRAM at the current VRAM Address.  Accessing $2007 will auto increment the destination address in $2006 by the VRAM Address Increment set by the $2000 register.
