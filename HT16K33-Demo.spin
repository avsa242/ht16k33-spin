{
    --------------------------------------------
    Filename: HT16K33-Demo.spin
    Author: Jesse Burt
    Created: Oct 11, 2018
    Updated: Oct 11, 2018
    Copyright (c) 2018
    See end of file for terms of use.
    --------------------------------------------
}

CON

    _clkmode    = cfg#_clkmode
    _xinfreq    = cfg#_xinfreq

OBJ

  cfg   : "core.con.client.parraldev"
  ser   : "com.serial.terminal"
  time  : "time"
  led   : "display.led.ht16k33.i2c"

VAR

    byte _offbuff[8]

PUB Main | x, y, buf, i, delay

    Setup
    buf := led.getaddr
    repeat
        repeat x from -7 to 6
            y := ||x
            point (7, y, 1)
            bytemove(buf, @_offbuff, 8)
            led.WriteBuff
            repeat i from 0 to 7
                _offbuff[i] >>= 1
            time.MSleep (100)

    repeat
        repeat x from 0 to 7
            bytefill(@_offbuff, 0, 8)
            point(x, 0, 1)
            time.MSleep (||cnt >> 24)
            bytemove(buf, @_offbuff, 8)
            led.WriteBuff
    
        repeat y from 1 to 7'
            bytefill(@_offbuff, 0, 8)
            point(7, y, 1)
            time.MSleep (||cnt >> 24)
            bytemove(buf, @_offbuff, 8)
            led.WriteBuff
    
        repeat x from 6 to 0
            bytefill(@_offbuff, 0, 8)
            point(x, 7, 1)
            time.MSleep (||cnt >> 24)
            bytemove(buf, @_offbuff, 8)
            led.WriteBuff
    
        repeat y from 6 to 1'
            bytefill(@_offbuff, 0, 8)
            point(0, y, 1)
            time.MSleep (||cnt >> 24)
            bytemove(buf, @_offbuff, 8)
            led.WriteBuff

PUB point(x, y, c)

    x := x + 7
    x := x // 8
    _offbuff[y] := (1 << x)

PUB Setup

    repeat until ser.Start (115_200)
    ser.Clear
    ser.Str (string("Serial terminal started", ser#NL))
    ifnot led.Start
        ser.Str (string("LED driver failed to start", ser#NL))
        time.MSleep (1000)
        repeat
    else
        ser.Str (string("LED driver started", ser#NL))
        ser.Hex (led.Oscillator (TRUE), 2)
        ser.NewLine
        ser.Hex (led.Display (TRUE), 2)

DAT
{
    --------------------------------------------------------------------------------------------------------
    TERMS OF USE: MIT License

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
    associated documentation files (the "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
    following conditions:

    The above copyright notice and this permission notice shall be included in all copies or substantial
    portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
    LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    --------------------------------------------------------------------------------------------------------
}
