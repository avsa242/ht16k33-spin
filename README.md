# ht16k33-spin 
---------------

This is a P8X32A/Propeller driver object for the Holtek HT16K33 LED Matrix/Segment IC.

## Salient Features

* Operation up to 1000kHz
* Control display brightness
* Control display blink
* Buffered display
* Render a pixel to buffer
* Render a bitmap font to buffer

## Requirements

* Requires one additional core/cog for the PASM I2C driver

## Limitations

* Early in development - feature lacking
* Written using Adafruit 8x8 backpack for development, the pixel layout of which differs from some other boards, so the display may not (yet) look correct on those
* Doesn't support LED segment displays, specifically
* Doesn't support alternate slave addresses

## TODO

* Implement support for non-Adafruit displays, other size displays, segmented displays
* Implement support for alternate slave addresses
