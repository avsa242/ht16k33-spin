{
    --------------------------------------------
    Filename: display.led.ht16k33.i2c.spin
    Author: Jesse Burt
    Created: Oct 11, 2018
    Updated: Mar 20, 2019
    Copyright (c) 2019
    See end of file for terms of use.
    --------------------------------------------
}

CON

    SLAVE_WR    = core#SLAVE_ADDR
    SLAVE_RD    = core#SLAVE_ADDR|1

    DEF_SCL     = 28
    DEF_SDA     = 29
    DEF_HZ      = core#I2C_DEF_FREQ

VAR

    byte _disp_power, _blink_freq, _disp_buff[8]

OBJ

    i2c     : "com.i2c"
    core    : "core.con.ht16k33"
    time    : "time"

PUB Null
''This is not a top-level object

PUB Start: okay                                         'Default to "standard" Propeller I2C pins and 400kHz

    okay := Startx (DEF_SCL, DEF_SDA, DEF_HZ)

PUB Startx(SCL_PIN, SDA_PIN, I2C_HZ): okay

    if lookdown(SCL_PIN: 0..31) and lookdown(SDA_PIN: 0..31)
        if I2C_HZ =< core#I2C_MAX_FREQ
            if okay := i2c.setupx (SCL_PIN, SDA_PIN, I2C_HZ)
                time.USleep (100)
                if i2c.present (SLAVE_WR)
                    Oscillator (TRUE)
                    RowInt (0)
                    Brightness (15)
                    Display (TRUE)
                    return okay
    return FALSE                                        'If we got here, something went wrong

PUB Stop

    Display (FALSE)
    Oscillator (FALSE)
    time.MSleep (100)
    i2c.terminate

PUB BlinkRate(rate_hz)

    case rate_hz
        2:      _blink_freq := %01 << 1
        1:      _blink_freq := %10 << 1
        0.5, 5: _blink_freq := %11 << 1
        OTHER:  _blink_freq := %00 << 1

    writeRegX (core#CMD_DISPSETUP, _blink_freq | _disp_power)

PUB Brightness(level)

    case level
        0..15:
        OTHER:
            return
    writeRegX (core#CMD_BRIGHTNESS, level)

PUB Char(chr) | row, msb, pos
'   7 0 1 2 3 4 5 6    _disp_buff[]
'   | | | | | | | |
'   0 1 2 3 4 5 6 7    LED physical layout
'   7 6 5 4 3 2 1 0    MSB..LSB

    repeat row from 0 to 7
{' Wasn't thinking...this won't work as-is with the SSD1306 5x8 font files, as they're rotated 90deg CW
 ' XXX TODO - translate them on-the-fly somehow???
        pos := font.baseaddr + (8 * chr) + row
        msb := byte[pos] >> 7 & 1
        byte[_disp_buff][row] := (msb << 7) | ((byte[pos] & $7F) >< 7)  'Put it back in place
}
        pos := @font + (8 * chr) + row
        msb := byte[pos] >> 7 & 1                                       'Isolate MSB
        _disp_buff[row] := (msb << 7) | ((byte[pos] & $7F) >< 7)        'Put it back in place
                                                                        ' and OR it together with the rest of the row
                                                                        ' reversing the 7 LSBs
    writeRegX ($00, @_disp_buff)

PUB DispAddr

    return @_disp_buff

PUB Display(enabled)

    case ||enabled
        0, 1: _disp_power := ||enabled
        OTHER:
            return
    writeRegX (core#CMD_DISPSETUP, _blink_freq | _disp_power)

PUB Oscillator(enabled)

    case ||enabled
        0, 1: enabled := ||enabled
        OTHER:
            return
    writeRegX (core#CMD_OSCILLATOR, enabled)

PUB PlotPoint (x, y, c)

    x := x + 7
    x := x // 8
    case c
        -1:
            _disp_buff[y] := !(1 << x)

        0:
            _disp_buff[y] &= (1 << x)

        1:
            _disp_buff[y] |= (1 << x)
        OTHER:
            return

    writeRegX ($00, @_disp_buff)

PUB RowInt(output_pin)

    case output_pin
        0, 1, 3:
        OTHER:
            return
    writeRegX (core#CMD_ROWINT, output_pin)

PUB WriteBuff

    writeRegX ($00, @_disp_buff)

PUB writeRegX(reg, buf_addr) | cmd_packet[2], i
' Write nr_bytes to register 'reg' stored in val
    cmd_packet.byte[0] := SLAVE_WR' | _addr_bit

    case reg
        $00:                                            'Display RAM
            cmd_packet.byte[1] := $00
            i2c.start
            i2c.wr_block (@cmd_packet, 2)
            repeat i from 0 to 7
                i2c.write ((byte[buf_addr][i]) & $FF)
                i2c.write ($00)
            i2c.stop

        $20, $80, $A0, $E0, $D9:                        'Control registers
            cmd_packet.byte[1] := reg | buf_addr
            i2c.start
            i2c.wr_block (@cmd_packet, 2)
            i2c.stop
        OTHER:
            return

DAT

   font byte    %01111100
        byte    %01000100
        byte    %01000100
        byte    %01000100
        byte    %01000100
        byte    %01000100
        byte    %01000100
        byte    %01111100

        byte    %00000100
        byte    %00000100
        byte    %00000100
        byte    %00000100
        byte    %00000100
        byte    %00000100
        byte    %00000100
        byte    %00000100

        byte    %01111100
        byte    %00000100
        byte    %00000100
        byte    %01111100
        byte    %01000000
        byte    %01000000
        byte    %01000000
        byte    %01111100

        byte    %01111100
        byte    %00000100
        byte    %00000100
        byte    %01111100
        byte    %00000100
        byte    %00000100
        byte    %00000100
        byte    %01111100

        byte    %01000100
        byte    %01000100
        byte    %01000100
        byte    %01111100
        byte    %00000100
        byte    %00000100
        byte    %00000100
        byte    %00000100

        byte    %01111100
        byte    %01000000
        byte    %01000000
        byte    %01111100
        byte    %00000100
        byte    %00000100
        byte    %00000100
        byte    %01111100

        byte    %01111100
        byte    %01000000
        byte    %01000000
        byte    %01111100
        byte    %01000100
        byte    %01000100
        byte    %01000100
        byte    %01111100

        byte    %01111100
        byte    %00000100
        byte    %00000100
        byte    %00000100
        byte    %00000100
        byte    %00000100
        byte    %00000100
        byte    %00000100

        byte    %01111100
        byte    %01000100
        byte    %01000100
        byte    %01111100
        byte    %01000100
        byte    %01000100
        byte    %01000100
        byte    %01111100

        byte    %01111100
        byte    %01000100
        byte    %01000100
        byte    %01111100
        byte    %00000100
        byte    %00000100
        byte    %00000100
        byte    %01111100

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
