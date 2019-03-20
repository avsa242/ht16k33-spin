{
    --------------------------------------------
    Filename: HT16K33-Demo.spin
    Description: Demo for the HT16K33 driver
    Author: Jesse Burt
    Created: Oct 11, 2018
    Updated: Mar 17, 2019
    Copyright (c) 2019
    See end of file for terms of use.
    --------------------------------------------
}

CON

    _clkmode    = cfg#_CLKMODE
    _xinfreq    = cfg#_XINFREQ

OBJ

  cfg   : "core.con.boardcfg.flip"
  ser   : "com.serial.terminal"
  time  : "time"
  led   : "display.led.ht16k33.i2c"

VAR

    byte _ser_cog, _offbuff[8]

PUB Main | x, y, i, delay, buf

    Setup
    buf := led.DispAddr

    repeat i from 0 to 9
        ser.Clear
        ser.Position (0, 0)
        led.Char (i)
        led.WriteBuff
        time.MSleep (500)

        repeat x from 0 to 7
            ser.Bin (byte[buf][x], 8)
            ser.NewLine

    repeat



    repeat x from 0 to 7
        led.PlotPoint (x, 0, 1)
        time.MSleep (500)
    repeat
    repeat y from 0 to 7
        led.PlotPoint (y, y, 1)
        led.PlotPoint (7-y, y, 1)
        led.WriteBuff
        time.MSleep (100)
    repeat
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

PUB WriteChar | buf, i, c

    buf := led.DispAddr
    repeat c from 0 to 9
        repeat i from 0 to 7
            byte[buf][i] := fnt[i + (c*8)] >< 7
        led.WriteBuff
        time.MSleep (1000)

PUB Setup

    repeat until _ser_cog := ser.Start (115_200)
    ser.Clear
    ser.Str (string("Serial terminal started", ser#NL))
    if led.Start
        ser.Str (string("LED driver started", ser#NL))
    else
        ser.Str (string("LED driver failed to start", ser#NL))
        time.MSleep (1000)
        led.Stop
        ser.Stop
        repeat

DAT
{
    fnt byte    %00011000
        byte    %00100100
        byte    %01000010
        byte    %01001010
        byte    %01010010
        byte    %01000010
        byte    %00100100
        byte    %00011000
}
    fnt byte    %10111000
        byte    %01000100
        byte    %01000100
        byte    %01001100
        byte    %01010100
        byte    %01100100
        byte    %01000100
        byte    %00111000

        byte    %00011000
        byte    %00011000
        byte    %00111000
        byte    %00001000
        byte    %00001000
        byte    %00001000
        byte    %00001000
        byte    %00111100

        byte    %00111000
        byte    %01000100
        byte    %01000100
        byte    %00001000
        byte    %00010000
        byte    %00010000
        byte    %00100000
        byte    %01111100

        byte    %00111000
        byte    %01000100
        byte    %00000100
        byte    %00011000
        byte    %00000100
        byte    %00000100
        byte    %01000100
        byte    %00111000

        byte    %00001000
        byte    %00011000
        byte    %00101000
        byte    %01001000
        byte    %01111100
        byte    %00001000
        byte    %00001000
        byte    %00001000

        byte    %01111100
        byte    %01000000
        byte    %01000000
        byte    %01111000
        byte    %00000100
        byte    %00000100
        byte    %01000100
        byte    %00111000

        byte    %00111000
        byte    %01000000
        byte    %01000000
        byte    %01111000
        byte    %01000100
        byte    %01000100
        byte    %01000100
        byte    %00111000

        byte    %01111100
        byte    %00000100
        byte    %00000100
        byte    %00001000
        byte    %00010000
        byte    %00010000
        byte    %00010000
        byte    %00010000

        byte    %00111000
        byte    %01000100
        byte    %01000100
        byte    %00111000
        byte    %01000100
        byte    %01000100
        byte    %01000100
        byte    %00111000

        byte    %00111000
        byte    %01000100
        byte    %01000100
        byte    %01000100
        byte    %00111100
        byte    %00000100
        byte    %00000100
        byte    %00111000


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
