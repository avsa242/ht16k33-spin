# ht16k33-spin 
--------------

This is a P8X32A/Propeller driver object for the Holtek HT16K33 LED Matrix/Segment IC (I2C).

**IMPORTANT**: This software is meant to be used with the [spin-standard-library](https://github.com/avsa242/spin-standard-library) (P8X32A) or [p2-spin-standard-library](https://github.com/avsa242/p2-spin-standard-library) (P2X8C4M64P). Please install the applicable library first before attempting to use this code, otherwise you will be missing several files required to build the project.

## Salient Features

* I2C connection at up to 400kHz
* Set display brightness, blinking
* Multiple address support
* Supports Adafruit variant of the 8x8 matrix
* Supports Adafruit 14-segment backpack 14-segment displays

## Requirements

P1/SPIN1:
* spin-standard-library
* P1/SPIN1: 1 extra core/cog for the PASM I2C engine
* Presence of lib.gfx.bitmap.spin library (only required for matrix driver)
* Presence of lib.terminal.spin (required for both matrix and 14-seg drivers)

P2/SPIN2:
* p2-spin-standard-library
* Presence of lib.gfx.bitmap.spin2 library (only required for matrix driver)
* Presence of lib.terminal.spin2 (required for both matrix and 14-seg drivers)

## Compiler Compatibility

* P1/SPIN1 OpenSpin (bytecode): Untested (deprecated)
* P1/SPIN1 FlexSpin (bytecode): OK, tested with 5.9.7-beta
* P1/SPIN1 FlexSpin (native): OK, tested with 5.9.7-beta
* ~~P2/SPIN2 FlexSpin (nu-code): FTBFS, tested with 5.9.7-beta~~
* P2/SPIN2 FlexSpin (native): OK, tested with 5.9.7-beta
* ~~BST~~ (incompatible - no preprocessor)
* ~~Propeller Tool~~ (incompatible - no preprocessor)
* ~~PNut~~ (incompatible - no preprocessor)

## Limitations

* Very early in development - may malfunction or outright fail to build
* Matrix driver written using Adafruit 8x8 backpack for development - pixel layout may differ from other brands or models
* 14-seg driver written using Adafruit 14-seg backpack for development - segment layout may differ from other brands or models
* Doesn't support 16 pixel-wide displays (planned)

