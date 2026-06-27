# ht16k33-spin 
--------------

This is a P8X32A/Propeller driver object for the Holtek HT16K33 LED Matrix/Segment IC (I2C).

**IMPORTANT**: This software is meant to be used with the [spin-standard-library](https://github.com/avsa242/spin-standard-library) (P8X32A) or [p2-spin-standard-library](https://github.com/avsa242/p2-spin-standard-library) (P2X8C4M64P). Please install the applicable library first before attempting to use this code, otherwise you will be missing several files required to build the project.


## Salient Features

* I2C connection at up to 400kHz
* Set display brightness, blinking
* Multiple address support
* Display variant support:
    * dot-matrix
    * 7-segment
    * 14-segment
* Horizontal scrolling (right to left)


## Requirements

P1/SPIN1:
* spin-standard-library
* P1/SPIN1: 1 extra core/cog for the PASM I2C engine
* graphics.common.spinh library (only required for matrix driver; provided by spin-standard-library)
* terminal.common.spinh (required for both matrix and 14-seg drivers; provided by spin-standard-library)

P2/SPIN2:
* p2-spin-standard-library
* graphics.common.spin2h library (only required for matrix driver; provided by p2-spin-standard-library)
* terminal.common.spin2h (required for both matrix and 14-seg drivers; provided by p2-spin-standard-library)


## Compiler Compatibility

| Processor | Language | Compiler               | Backend      | Status                |
|-----------|----------|------------------------|--------------|-----------------------|
| P1        | SPIN1    | FlexSpin (7.6.11)      | Bytecode     | OK                    |
| P1        | SPIN1    | FlexSpin (7.6.11)      | Native/PASM  | OK                    |
| P2        | SPIN2    | FlexSpin (7.6.11)      | NuCode       | OK                    |
| P2        | SPIN2    | FlexSpin (7.6.11)      | Native/PASM2 | OK                    |

(other versions or toolchains not listed are __not supported__, and _may or may not_ work)


## Hardware compatibility

* Tested using Adafruit 8x8 LED matrix
* Tested using Adafruit 7-segment LED
* Tested using Adafruit 14-segment LED


## Limitations

* Matrix driver written using Adafruit 8x8 backpack for development - pixel layout may differ from other brands or models
* led-seg driver written using Adafruit 7 and 14-seg backpack for development - segment layout may differ from other brands or models
* Doesn't yet support 16 pixel-wide dot-matrix displays
* Doesn't yet support multiple displays simultaneously

