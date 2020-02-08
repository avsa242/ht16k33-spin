{
    --------------------------------------------
    Filename: display.led.ht16k33.i2c.spin
    Description: Driver for HT16K33-based LED matrix displays
    Author: Jesse Burt
    Created: Oct 11, 2018
    Updated: Feb 8, 2020
    Copyright (c) 2020
    See end of file for terms of use.
    --------------------------------------------
}

#define HT16K33-ADAFRUIT
#include "lib.gfx.bitmap.spin"

CON

    MAX_COLOR   = 1

    SLAVE_WR    = core#SLAVE_ADDR
    SLAVE_RD    = core#SLAVE_ADDR|1

    DEF_SCL     = 28
    DEF_SDA     = 29
    DEF_HZ      = core#I2C_DEF_FREQ

VAR

    long _draw_buffer
    word _buff_sz
    byte _disp_width, _disp_height, _disp_xmax, _disp_ymax
    byte _disp_power, _blink_freq, _disp_buff[8]

OBJ

    i2c     : "com.i2c"
    core    : "core.con.ht16k33"
    time    : "time"

PUB Null
''This is not a top-level object

PUB Startx(width, height, SCL_PIN, SDA_PIN, I2C_HZ, dispbuffer_address): okay

    if lookdown(SCL_PIN: 0..31) and lookdown(SDA_PIN: 0..31)
        if I2C_HZ =< core#I2C_MAX_FREQ
            if okay := i2c.setupx (SCL_PIN, SDA_PIN, I2C_HZ)
                time.USleep (100)
                if i2c.present (SLAVE_WR)
                    Defaults
                    _disp_width := width
                    _disp_height := height
                    _disp_xmax := _disp_width-1
                    _disp_ymax := _disp_height-1
                    _buff_sz := (_disp_width * _disp_height) / 8
                    Address(dispbuffer_address)

                    return okay
    return FALSE                                        'If we got here, something went wrong

PUB Stop

    DisplayPower (FALSE)
    Oscillator (FALSE)
    time.MSleep (100)
    i2c.terminate

PUB Defaults

    Oscillator (TRUE)
    RowInt (0)
    Brightness (15)
    DisplayPower (TRUE)

PUB Address(addr)
' Set framebuffer address
    case addr
        $0004..$7FFF-_buff_sz:
            _draw_buffer := addr
            result := _draw_buffer
            return
        OTHER:
            result := _draw_buffer
            return

PUB BlinkRate(rate_hz)
' Set blink rate of display, in Hz
'   Valid values: 0.5, 5, 1, 2
'   Any other value disables blinking
    case rate_hz
        2:      _blink_freq := %01 << 1
        1:      _blink_freq := %10 << 1
        0.5, 5: _blink_freq := %11 << 1
        OTHER:  _blink_freq := %00 << 1

    writeReg (core#CMD_DISPSETUP, _blink_freq | _disp_power)

PUB Brightness(level)
' Set display brightness
'   Valid values: 0..15
'   Any other value is ignored
    case level
        0..15:
        OTHER:
            return
    writeReg (core#CMD_BRIGHTNESS, level)

PUB ClearAccel
' Dummy method

PUB DisplayPower(enabled)
' Power on display
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value is ignored
    case ||enabled
        0, 1: _disp_power := ||enabled
        OTHER:
            return

    writeReg (core#CMD_DISPSETUP, _blink_freq | _disp_power)

PUB Oscillator(enabled)
' Enable the oscillator
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value is ignored
    case ||enabled
        0, 1: enabled := ||enabled
        OTHER:
            return
    writeReg (core#CMD_OSCILLATOR, enabled)

PUB RowInt(output_pin)

    case output_pin
        0, 1, 3:
        OTHER:
            return
    writeReg (core#CMD_ROWINT, output_pin)

PUB Update
' Write display buffer to display
    writeReg ($00, _draw_buffer)

PRI writeReg(reg, buff_addr) | cmd_packet[2], i
' Write nr_bytes to register 'reg' stored in val
    cmd_packet.byte[0] := SLAVE_WR' | _addr_bit

    case reg
        $00:                                            'Display RAM
            cmd_packet.byte[1] := $00
            i2c.start
            i2c.wr_block (@cmd_packet, 2)
            repeat i from 0 to 7
                i2c.write ((byte[buff_addr][i]) & $FF)
                i2c.write ($00)
            i2c.stop

        $20, $80, $A0, $E0, $D9:                        'Control registers
            cmd_packet.byte[1] := reg | buff_addr
            i2c.start
            i2c.wr_block (@cmd_packet, 2)
            i2c.stop
        OTHER:
            return

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
