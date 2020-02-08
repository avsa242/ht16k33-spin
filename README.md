# ht16k33-spin 
---------------

This is a P8X32A/Propeller driver object for the Holtek HT16K33 LED Matrix/Segment IC (I2C).

## Salient Features

* Operation up to 1MHz
* Support for setting display brightness, blinking
* Support for generic bitmap graphics library

## Requirements

* P1/SPIN1: 1 extra core/cog for the PASM I2C driver
* Presence of lib.gfx.bitmap library

## Compiler compatibility

* P1/SPIN1: ~~Propeller Tool~~ Unsupported - requires a compiler with preprocessor support
* P1/SPIN1: OpenSpin (tested with 1.00.81)

## Limitations

* Very early in development - may malfunction or outright fail to build
* Written using Adafruit 8x8 backpack for development, the pixel layout of which differs from some other boards, so the display may not (yet) look correct on those
* Doesn't support LED segment displays, specifically
* Doesn't support alternate slave addresses
* Doesn't support 16 pixel-wide displays

## TODO

- [ ] Implement support for non-Adafruit displays, other size displays, segmented displays
- [ ] Implement support for alternate slave addresses
