{
---------------------------------------------------------------------------------------------------
    Filename:       HT16K33-SimpleDemo.spin
    Description:    Simplified Demo of the HT16K33 driver
    Author:         Jesse Burt
    Started:        Nov 21, 2020
    Updated:        Jan 28, 2024
    Copyright (c) 2024 - See end of file for terms of use.
---------------------------------------------------------------------------------------------------

    NOTE: -DFNT_POS_NOGRID must be defined when building for the text portion of this demo
        to function correctly.

}

#define FNT_POS_NOGRID
#pragma exportdef(FNT_POS_NOGRID)

CON

    _clkmode    = cfg#_clkmode
    _xinfreq    = cfg#_xinfreq


OBJ

    cfg:    "boardcfg.flip"
    ser:    "com.serial.terminal.ansi" | SER_BAUD=115_200
    time:   "time"
    matrix: "display.led.ht16k33" | SCL=28, SDA=29, I2C_FREQ=400_000, I2C_ADDR=%000, ...
                                    WIDTH=8, HEIGHT=8
    fnt:    "font.5x8"

PUB main{} | i

    setup{}
    matrix.defaults{}
    matrix.set_font(fnt.ptr(), fnt.setup())

    matrix.fgcolor(1)                           ' fg/bg color of following text
    matrix.bgcolor(0)                           '   (colors: -1, 0, 1)
    matrix.char_attrs(matrix#DRAWBG)
    repeat 5
        repeat i from 0 to 9
            matrix.pos_xy(0, 0)
            matrix.putchar(48+i)                ' ASCII 48+i (nums 0..9)
            time.msleep(100)
            matrix.show{}                       ' show display

    time.sleep(2)
    matrix.clear{}

    matrix.box(0, 0, matrix.XMAX, matrix.YMAX, 1, false)      ' x1, y1, x2, y2, color, fill
    matrix.show{}

    time.sleep(2)
    matrix.clear{}

    matrix.box(0, 0, 5, 5, -1, true)
    matrix.box(matrix.XMAX, matrix.YMAX, matrix.XMAX-5, matrix.YMAX-5, -1, true)
    matrix.show{}

    time.sleep(2)
    matrix.clear{}

    matrix.circle(3, 3, 4, 1, false)            ' x, y, radius, color, fill
    matrix.show{}

    time.sleep(2)
    matrix.clear{}

    matrix.line(0, 0, 4, 4, 1)                  ' x1, y1, x2, y2, color
    matrix.show{}

    time.sleep(2)
    matrix.clear{}

    matrix.plot(5, 7, 1)                        ' x, y, color
    matrix.show{}

    time.sleep(2)
    matrix.clear{}

    repeat

PUB setup{}

    ser.start()
    time.msleep(30)
    ser.clear{}
    ser.strln(@"Serial terminal started")
    if ( matrix.start() )
        ser.strln(@"HT16K33 driver started")
    else
        ser.strln(@"HT16K33 driver failed to start - halting")
        repeat

DAT
{
Copyright 2024 Jesse Burt

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}

