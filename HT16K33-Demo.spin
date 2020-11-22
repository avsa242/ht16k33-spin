{
    --------------------------------------------
    Filename: HT16K33-Demo.spin
    Description: Demo of the HT16K33 driver
    Author: Jesse Burt
    Created: Oct 11, 2018
    Updated: Feb 8, 2020
    Copyright (c) 2020
    See end of file for terms of use.
    --------------------------------------------
}

' Optionally undef/comment out to disable the terminal framerate monitor
#define FPS_MON_ENABLE

CON

    _clkmode    = cfg#_CLKMODE
    _xinfreq    = cfg#_XINFREQ

' -- User-modifiable constants
    SER_BAUD    = 115_200
    LED         = cfg#LED1

    I2C_SCL     = 1
    I2C_SDA     = 0
    I2C_HZ      = 3_400_000

    WIDTH       = 8
    HEIGHT      = 8
' --

    BUFFSZ      = (WIDTH * HEIGHT) / 8
    XMAX        = WIDTH-1
    YMAX        = HEIGHT-1

OBJ

    cfg     : "core.con.boardcfg.flip"
    ser     : "com.serial.terminal.ansi"
    time    : "time"
    int     : "string.integer"
    matrix  : "display.led.ht16k33.i2c"
    fnt     : "font.5x8"

VAR

    long _fps_mon_stack[50]
    long _rndSeed
    byte _framebuff[BUFFSZ]
    byte _frames, _fps_mon_cog, _ser_cog
    byte _ser_row

PUB Main

    Setup

    _frames := 0
    _ser_row := 3

    Demo_Greet
    time.Sleep(5)
    matrix.ClearAll

    Demo_Char (1000)
    matrix.ClearAll

    Demo_Circle(1000)
    matrix.ClearAll

    Demo_Line(500)
    matrix.ClearAll

    Demo_LineSweep(250)
    matrix.ClearAll

    Stop

PUB Demo_Char(reps) | ch
' Sequentially draws the whole font table to the screen, then random characters
    _ser_row++
    ser.Position(0, _ser_row)
    ser.Str(string("Demo_Char"))

    matrix.FGColor(1)
    matrix.BGColor(0)
    ch := $00
    repeat reps/2
        ch++
        if ch > fnt#LASTCHAR
            ch := $00
        matrix.Position(0, 0)
        matrix.Char (ch)
        matrix.Update
        _frames++

    repeat reps/2
        matrix.Position (0, 0)
        matrix.Char (rnd(fnt#LASTCHAR))
        matrix.Update
        _frames++

PUB Demo_Circle(reps) | x, y, r
' Draws circles at random locations
    _ser_row++
    ser.Position(0, _ser_row)
    ser.Str(string("Demo_Circle"))

    repeat reps
        x := rnd(XMAX)
        y := rnd(YMAX)
        r := rnd(YMAX/2)
        matrix.Circle (x, y, r, -1)
        matrix.Update
        _frames++

PUB Demo_Greet | ch, idx
' Display the banner/greeting on the matrix
    _ser_row++
    _frames := 0
    ser.Position(0, _ser_row)
    ser.Str(string("Demo_Greet"))

    matrix.FGColor(1)
    matrix.BGColor(0)
    ch := idx := 0

    repeat
        matrix.Position(0, 0)
        ch := byte[@greet_str][idx++]
        if ch == 0
            quit
        matrix.Char(ch)
        matrix.Update
        time.MSleep(333)

PUB Demo_Line (reps)
' Draws random lines with color -1 (invert)
    _ser_row++
    ser.Position(0, _ser_row)
    ser.Str(string("Demo_Line"))

    repeat reps
        matrix.Line (rnd(XMAX), rnd(YMAX), rnd(XMAX), rnd(YMAX), -1)
        matrix.Update
        _frames++

PUB Demo_LineSweep(reps) | x, y

    _ser_row++
    ser.Position(0, _ser_row)
    ser.Str(string("Demo_LineSweep"))

    repeat reps
        repeat x from 0 to XMAX step 1
            matrix.Clear
            matrix.Line (x, 0, XMAX-x, YMAX, 1)
            matrix.Update
            _frames++
        repeat y from 0 to YMAX step 1
            matrix.Clear
            matrix.Line (XMAX, y, 0, YMAX-y, 1)
            matrix.Update
            _frames++

PUB RND(maxval) | i
' Return random number up to maxval
    i :=? _rndSeed
    i >>= 16
    i *= (maxval + 1)
    i >>= 16

    return i

PUB FPS_mon
' Display to the serial terminal approximate render speed, in frames per second
    repeat
        time.MSleep (1000)
        ser.Position (20, _ser_row)
        ser.Str (string("FPS: "))
        ser.Str (int.DecZeroed (_frames, 3))
        _frames := 0

PUB Setup

    ser.start(SER_BAUD)
    time.msleep(30)
    ser.clear{}
    ser.strln(string("Serial terminal started"))
    if matrix.startx(WIDTH, HEIGHT, I2C_SCL, I2C_SDA, I2C_HZ, @_framebuff)
        ser.strln(string("HT16K33 driver started"))
        matrix.fontsize(6, 8)
        matrix.fontaddress(fnt.baseaddr{})
    else
        ser.strln(string("HT16K33 driver failed to start - halting"))
        matrix.stop{}
        time.msleep(5)
        ser.stop{}

#ifdef FPS_MON_ENABLE
    _fps_mon_cog := cognew(FPS_mon, @_fps_mon_stack)  'Start framerate monitor in another cog/core
#endif

PUB Stop{}

    matrix.stop{}

    if _fps_mon_cog
        cogstop(_fps_mon_cog)
    if _ser_cog
        cogstop(_ser_cog)

DAT

    greet_str   byte    "HT16K33 on the Parallax P8X32A", 0

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
