{
----------------------------------------------------------------------------------------------------
    Filename:       HT16K33-14SegDemo.spin
    Description:    Demo of the HT16K33 driver
        * 14-segment displays
    Author:         Jesse Burt
    Started:        Jun 22, 2021
    Updated:        Jun 27, 2026
    Copyright (c) 2026 - See end of file for terms of use.
----------------------------------------------------------------------------------------------------
}

con

    _clkmode    = xtal1+pll16x
    _xinfreq    = 5_000_000


obj

    ser:    "com.serial.terminal.ansi" | SER_BAUD=115_200
    disp:   "display.led-seg.ht16k33" | SCL=28, SDA=29, I2C_FREQ=400_000, I2C_ADDR=%000, ...
                                        WIDTH=4, HEIGHT=1
    font:   "font.seg.adafruit-14seg"
    time:   "time"
    fs:     "string.float"

    ' WIDTH, HEIGHT: number of digits/characters width and height the display has
    ' The demo is written to work best with a 4x1 display
    ' If your display has a dedicated colon (:), add one to the WIDTH
    '   (e.g., for a 4x1 digit display with a colon in the middle, set WIDTH=5 instead of 4)


dat

    scrolltest byte "THIS IS A TEST OF THE SCROLLING FUNCTIONALITY", 0


pub main() | i, b

    setup()
    disp.hscroll_enabled(true)
    b := @scrolltest

    repeat strsize(b)
        disp.putchar(byte[b++])
        disp.show()
        time.msleep(250)

    time.msleep(2_000)

    disp.blink_rate(2)
    demo_msg(@"DEMO")
    time.sleep(2)
    disp.blink_rate(0)
    time.sleep(1)

    demo_msg(@"CHAR")                           ' display printable ASCII chars

    repeat i from 32 to 126
        disp.clear()
        disp.putchar(i)
        disp.show()
        time.msleep(100)
    time.sleep(2)


    demo_msg(@"STR")                            ' display strings

    disp.puts(@"This")
    disp.show()

    time.sleep(1)
    disp.clear()
    disp.puts(@"is")
    disp.show()

    time.sleep(1)
    disp.clear()
    disp.puts(@"the")
    disp.show()

    time.sleep(1)
    disp.clear()
    disp.puts(@"STR")
    disp.show()

    time.sleep(1)
    disp.clear()
    disp.puts(@"demo")
    disp.show()

    time.sleep(2)


    demo_msg(@"HEX")                            ' display hexadecimal numbers

    repeat i from 0 to $1ff
        disp.clear()
        disp.puthex(i, 4)
        disp.show()
    time.sleep(2)

    demo_msg(@"BIN")                            ' display binary numbers

    repeat i from 0 to %1111
        disp.clear()
        disp.printf(@"%04.4b", i)
        disp.show()
        time.msleep(200)
    time.sleep(2)

    demo_msg(@"DEC")                            ' display decimal numbers

    repeat i from 0 to 1000
        disp.clear()
        disp.printf(@"%4.4d", i)
        disp.show()
    time.sleep(2)

    demo_msg(@"FLT")
    disp.clear()
    disp.puts(fs.float_str(3.141))
    disp.show()
    time.sleep(1)

    disp.clear()
    disp.puts(fs.float_str(31.41))
    disp.show()
    time.sleep(1)

    disp.clear()
    disp.puts(fs.float_str(314.1))
    disp.show()
    time.sleep(1)

    disp.clear()
    disp.puts(fs.float_str(3141.0))
    disp.show()

    time.sleep(2)

    demo_msg(@"TYPE")                           ' echo characters typed into the serial terminal

    repeat
        b := ser.getchar()
        disp.putchar(b)
        disp.show()


pri demo_msg(ptr_str)
' Clear the display, show a message, wait 2 seconds, then clear again
    disp.clear()
    disp.puts(ptr_str)
    disp.show()
    time.sleep(2)
    disp.clear
    disp.show()


pub setup()

    ser.start()
    time.msleep(30)
    ser.clear()
    ser.strln(@"Serial terminal started")

    if ( disp.start() )
        ser.strln(@"HT16K33 driver started")
        disp.defaults()
    else
        ser.str(@"HT16K33 driver failed to start - halting")
        repeat

    disp.set_font( font.setup() )


dat
{
Copyright 2026 Jesse Burt

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

