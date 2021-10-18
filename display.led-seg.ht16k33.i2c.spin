{
    --------------------------------------------
    Filename: display.led-seg.ht16k33.i2c.spin
    Description: Driver for HT16K33-based LED segment displays
    Author: Jesse Burt
    Copyright (c) 2021
    Created: Jun 22, 2021
    Updated: Jun 22, 2021
    See end of file for terms of use.
    --------------------------------------------
}

CON

    SLAVE_WR    = core#SLAVE_ADDR
    SLAVE_RD    = core#SLAVE_ADDR|1

    DEF_SCL     = 28
    DEF_SDA     = 29
    DEF_HZ      = 100_000

' Display visibility
    OFF         = 0
    ON          = 1

VAR

    long _col, _row, _disp_width, _disp_height, _disp_xmax, _disp_ymax    
    word _disp_buff[7]                           ' 112 bits/segments
    byte _dispsetup
    byte _addr_bits
    byte _lastchar

OBJ

    i2c     : "com.i2c"
    core    : "core.con.ht16k33"
    time    : "time"

PUB Null{}
' This is not a top-level object

PUB Startx(SCL_PIN, SDA_PIN, I2C_HZ, ADDR_BITS, WIDTH, HEIGHT): status
' SCL_PIN, SDA_PIN, I2C_HZ: I2C bus I/O pins and speed
' ADDR_BITS: specify LSBs of slave address (%000..%111)
' WIDTH, HEIGHT: dimensions of display, in digits/characters
    if lookdown(SCL_PIN: 0..31) and lookdown(SDA_PIN: 0..31) and {
}   I2C_HZ =< core#I2C_MAX_FREQ
        if lookdown(ADDR_BITS: %000..%111)
            if (status := i2c.init(SCL_PIN, SDA_PIN, I2C_HZ))
                time.usleep(core#T_POR)         ' wait for device startup
                _addr_bits := ADDR_BITS << 1
                _disp_width := WIDTH
                _disp_height := HEIGHT
                _disp_xmax := WIDTH-1
                _disp_ymax := HEIGHT-1
                if i2c.present(SLAVE_WR | _addr_bits) ' test device presence
                    clear{}
                    return
    ' if this point is reached, something above failed
    ' Double check I/O pin assignments, connections, power
    ' Lastly - make sure you have at least one free core/cog
    return FALSE

PUB Stop{}

    displayvisibility(FALSE)
    oscenabled(FALSE)
    time.msleep(100)
    i2c.deinit{}

PUB Defaults{}

    oscenabled(TRUE)
    brightness(15)
    displayvisibility(TRUE)

PUB BlinkRate(rate)
' Set blink rate of display, in Hz
'   Valid values: 0_5 (0.5), 1, 2
'   Any other value disables blinking
    case rate
        0:
            rate := 0
        0_5:
            rate := %11 << core#BLINK
        1:
            rate := %10 << core#BLINK
        2:
            rate := %01 << core#BLINK
        other:
            return

    _dispsetup := ((_dispsetup & core#BLINK_MASK) | rate)
    writereg(core#DISPSETUP, _dispsetup)

PUB Brightness(level)
' Set display brightness
'   Valid values: 0..15
'   Any other value is ignored
    case level
        0..15:
        other:
            return
    writereg(core#BRIGHTNESS, level)

PUB Char(c) | cmd_pkt, i
' Write character to display
'   NOTE: Interprets control characters
    case c
        BS, DEL:                                ' backspace/delete
            prevdigit{}                         ' move back to previous digit
            updatebuff(" ")                     '   and display a SPACE over it
        LF:
            movedown{}
        CB:                                     ' clear/form feed
            clear{}
        CR:
            positionx(0) 
        " ".."-", "/".."~":                     ' printable characters
            _lastchar := c
            updatebuff(c)
            nextdigit{}
        ".":                                    ' period/decimal point
            if lookdown(_lastchar: "0".."9")    ' if previous char was a num,
                _lastchar := "."                '   draw the decimal point in
                prevdigit{}                     '   the same digit as the num
                updatebuff(c)
                nextdigit{}
            else
                _lastchar := "."
                updatebuff(c)
                nextdigit{}
        other:
            return

    cmd_pkt.byte[0] := SLAVE_WR | _addr_bits
    cmd_pkt.byte[1] := core#DISP_RAM
    i2c.start{}
    i2c.wrblock_lsbf(@cmd_pkt, 2)
    repeat i from 0 to 7
        i2c.wrword_lsbf(_disp_buff[i])
    i2c.stop{}

PUB Clear{}
' Clear display
    repeat 7
        char(" ")
    position(0, 0)

PUB DisplayVisibility(state)
' Enable display visibility
'   Valid values: TRUE/ON (-1 or 1), FALSE/OFF (0)
'   Any other value is ignored
'   NOTE: This doesn't affect display RAM contents;
'       only whether it's currently displayed or not
    case ||(state)
        OFF, ON:
            state := ||(state)
        other:
            return

    _dispsetup := ((_dispsetup & core#ONOFF_MASK) | state)
    writereg(core#DISPSETUP, _dispsetup)

PUB MoveDown{}
' Move cursor down one row
'   NOTE: Wraps around to the first row
    _row++
    if _row > _disp_ymax
        _row := 0

PUB MoveLeft{}
' Move cursor left one column
'   NOTE: Wraps around to the last column
    _col--
    if _col < 0
        _col := _disp_xmax

PUB MoveRight{}
' Move cursor right one column
'   NOTE: Wraps around to the first column
    _col++
    if _col > _disp_xmax
        _col := 0

PUB MoveUp{}
' Move cursor up one row
'   NOTE: Wraps around to the last row
    _row--
    if _row < 0
        _row := _disp_ymax

PUB OscEnabled(state)
' Enable the oscillator
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value is ignored
    case ||(state)
        0, 1: state := ||(state)
        other:
            return
    writereg(core#OSCILLATOR, state)

PUB Position(x, y)
' Set cursor position
    if (x => 0) and (x =< _disp_xmax) and (y => 0) and (y =< _disp_ymax)
        _col := x
        _row := y

PUB PositionX(x)
' Set cursor X position
    if (x => 0) and (x =< _disp_xmax)
        _col := x

PUB PositionY(y)
' Set cursor Y position
    if (y => 0) and (y =< _disp_ymax)
        _row := y

PRI nextDigit{}
' Advance to next display digit
'   NOTE:
'       * Wraps around to the first column
'       * Wraps around to first row
    _col++
    if _col > _disp_xmax
        _col := 0
        movedown{}

PRI prevDigit{}
' Move back to previous display digit
'   NOTE:
'       * Wraps around to the last column
'       * Wraps around to last row
    _col--
    if _col < 0
        _col := _disp_xmax
        moveup{}

PRI updateBuff(c)
' Update display buffer with character 'c'
    if c == "."
        ' if drawing a period/decimal point, OR it in with the current digit's
        '   data, so it doesn't clear the digit and just draw the period
        _disp_buff[(_row * _disp_width) + _col] |= _fnt_tbl[c-32]
    else
        ' otherwise, just write the digit data
        _disp_buff[(_row * _disp_width) + _col] := _fnt_tbl[c-32]

PRI writeReg(reg_nr, ptr_buff) | cmd_pkt[2], i
' Write reg_nr to device from ptr_buff
    case reg_nr
        core#OSCILLATOR, core#DISPSETUP, core#ROWINT, {
        } core#BRIGHTNESS:                      ' Control registers
            cmd_pkt.byte[0] := SLAVE_WR | _addr_bits
            cmd_pkt.byte[1] := reg_nr | ptr_buff
            i2c.start{}
            i2c.wrblock_lsbf(@cmd_pkt, 2)
            i2c.stop{}
        other:
            return

DAT

_fnt_tbl    word    %0000_0000_0000_0000    ' (SP) - 32/$20
            word    %0001_0010_0000_0000
            word    %0000_0000_0010_0010    ' "
            word    %0001_0010_1100_1110    ' #
            word    %0001_0010_1110_1101    ' $
            word    %0010_1101_1110_0100    ' %
            word    %0010_0100_1101_1010    ' &
            word    %0000_0100_0000_0000    ' '
            word    %0000_0000_0011_1001    ' (
            word    %0000_0000_0000_1111    ' )
            word    %0011_1111_0000_0000    ' *
            word    %0001_0010_1100_0000    ' +
            word    %0000_1000_0000_0000    ' ,
            word    %0000_0000_1100_0000    ' -
            word    %0100_0000_0000_0000    ' .
            word    %0000_1100_0000_0000    ' /

            word    %0000_1100_0011_1111    ' 0 - 48/$30
            word    %0000_0000_0000_0110    ' 1
            word    %0000_0000_1101_1011    ' 2
            word    %0000_0000_1100_1111    ' 3
            word    %0000_0000_1110_0110    ' 4
            word    %0000_0000_1110_1101    ' 5
            word    %0000_0000_1111_1101    ' 6
            word    %0000_0000_0000_0111    ' 7
            word    %0000_0000_1111_1111    ' 8
            word    %0000_0000_1110_1111    ' 9

            word    %0001_0010_0000_0000    ' :
            word    %0000_1010_0000_0000    ' ;
            word    %0010_0100_0000_0000    ' <
            word    %0000_0000_1100_1000    ' =
            word    %0000_1001_0000_0000    ' >
            word    %0001_0000_1000_0011    ' ?
            word    %0010_0000_1011_0111    ' @

            word    %0000_0000_1111_0111    ' A - 65/$41
            word    %0001_0010_1000_1111    ' B
            word    %0000_0000_0011_1001    ' C
            word    %0001_0010_0000_1111    ' D
            word    %0000_0000_1111_1001    ' E
            word    %0000_0000_1111_0001    ' F
            word    %0000_0000_1011_1101    ' G
            word    %0000_0000_1111_0110    ' H
            word    %0001_0010_0000_1001    ' I
            word    %0000_0000_0001_1110    ' J
            word    %0010_0100_0111_0000    ' K
            word    %0000_0000_0011_1000    ' L
            word    %0000_0101_0011_0110    ' M
            word    %0010_0001_0011_0110    ' N
            word    %0000_0000_0011_1111    ' O
            word    %0000_0000_1111_0011    ' P
            word    %0010_0000_0011_1111    ' Q
            word    %0010_0000_1111_0011    ' R
            word    %0010_0001_0000_1001    ' S
            word    %0001_0010_0000_0001    ' T
            word    %0000_0000_0011_1110    ' U
            word    %0000_1100_0011_0000    ' V
            word    %0010_1000_0011_0110    ' W
            word    %0010_1101_0000_0000    ' X
            word    %0001_0000_1110_0010    ' Y
            word    %0000_1100_0000_1001    ' Z

            word    %0000_0000_0011_1001    ' (
            word    %0010_0001_0000_0000    ' \
            word    %0000_0000_0000_1111    ' )
            word    %0000_0100_0000_0010    ' ^
            word    %0000_0000_0000_1000    ' _
            word    %0000_0001_0000_0000    ' `

            word    %0000_0000_1101_1111    ' a
            word    %0000_0000_1111_1100    ' b
            word    %0000_0000_1101_1000    ' c
            word    %0000_0000_1101_1110    ' d
            word    %0000_0000_0111_1001    ' e
            word    %0000_0000_0111_0001    ' f
            word    %0000_0001_1000_1111    ' g
            word    %0000_0000_1111_0100    ' h
            word    %0001_0000_0000_0000    ' i
            word    %0000_0000_0000_1110    ' j
            word    %0011_0110_0000_0000    ' k
            word    %0001_0010_0000_0000    ' l
            word    %0001_0000_1101_0100    ' m
            word    %0000_0000_1101_0100    ' n
            word    %0000_0000_1101_1100    ' o
            word    %0000_0100_0111_0001    ' p
            word    %0010_0000_1110_0011    ' q
            word    %0000_0000_0101_0000    ' r
            word    %0000_0001_1000_1101    ' s
            word    %0000_0000_0111_1000    ' t
            word    %0000_0000_0001_1100    ' u
            word    %0000_1000_0001_0000    ' v
            word    %0010_1000_0001_0100    ' w
            word    %0010_1101_0000_0000    ' x
            word    %0001_0000_1110_0010    ' y
            word    %0000_1100_0000_1001    ' z

            word    %0000_1001_0100_1001    ' {
            word    %0001_0010_0000_0000    ' |
            word    %0010_0100_1000_1001    ' }
            word    %0000_0000_1100_0000    ' ~
            word    %0000_0000_0000_0000    ' (DEL)

#include "lib.terminal.spin"

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