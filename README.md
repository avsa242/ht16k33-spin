# ht16k33-spin 
---------------

This is a P8X32A/Propeller driver object for the Holtek HT16K33 LED Matrix/Segment IC (I2C).

**IMPORTANT**: This software is meant to be used with the [spin-standard-library](https://github.com/avsa242/spin-standard-library) (P8X32A) or [p2-spin-standard-library](https://github.com/avsa242/p2-spin-standard-library) (P2X8C4M64P). Please install the applicable library first before attempting to use this code, otherwise you will be missing several files required to build the project.

## Salient Features

* Operation up to 1MHz
* Support for setting display brightness, blinking
* Support for generic bitmap graphics library

## Requirements

P1/SPIN1:
* spin-standard-library
* P1/SPIN1: 1 extra core/cog for the PASM I2C driver

P2/SPIN2:
* p2-spin-standard-library

Presence of lib.gfx.bitmap library

## Compiler compatibility

* P1/SPIN1: OpenSpin (tested with 1.00.81)
* P2/SPIN2: FastSpin (tested with 4.1.10-beta)
* ~~BST~~ (incompatible - no preprocessor)
* ~~Propeller Tool~~ (incompatible - no preprocessor)
* ~~PNut~~ (incompatible - no preprocessor)

## Limitations

* Very early in development - may malfunction or outright fail to build
* Written using Adafruit 8x8 backpack for development, the pixel layout of which differs from some other boards, so the display may not (yet) look correct on those
* Doesn't support LED segment displays, specifically
* Doesn't support alternate slave addresses
* Doesn't support 16 pixel-wide displays

## TODO

- [ ] Implement support for non-Adafruit displays, other size displays, segmented displays
- [ ] Implement support for alternate slave addresses
