{
    --------------------------------------------
    Filename: display.led.ht16k33.i2c.spin
    Description: Driver for HT16K33-based LED matrix displays
    Author: Jesse Burt
    Created: Oct 11, 2018
    Updated: Nov 22, 2020
    Copyright (c) 2020
    See end of file for terms of use.
    --------------------------------------------
}

#define HT16K33-ADAFRUIT
#include "lib.gfx.bitmap.spin"

CON

    MAX_COLOR   = 1
    BYTESPERPX  = 1

    SLAVE_WR    = core#SLAVE_ADDR
    SLAVE_RD    = core#SLAVE_ADDR|1

    DEF_SCL     = 28
    DEF_SDA     = 29
    DEF_HZ      = 100_000

VAR

    long _ptr_drawbuffer
    word _buff_sz
    byte _disp_width, _disp_height, _disp_xmax, _disp_ymax
    byte _disp_power, _blink_freq, _disp_buff[8]
    byte _addr_bits
    byte BYTESPERLN

OBJ

    i2c     : "com.i2c"
    core    : "core.con.ht16k33"
    time    : "time"

PUB Null{}
' This is not a top-level object

PUB Startx(width, height, SCL_PIN, SDA_PIN, I2C_HZ, ADDR_BITS, ptr_disp): okay
' width, height: dimensions of matrix, in pixels
' SCL_PIN, SDA_PIN, I2C_HZ: I2C bus I/O pins and speed
' ADDR_BITS: specify LSBs of slave address (%000..%111)
' ptr_disp: pointer to display buffer, of minimum (W*H)/8 bytes
'   (e.g., for an 8x8 matrix, 8*8=64 / 8 = 8 bytes)
    if lookdown(SCL_PIN: 0..31) and lookdown(SDA_PIN: 0..31)
        if I2C_HZ =< core#I2C_MAX_FREQ
            if lookdown(ADDR_BITS: %000..%111)
                time.usleep(core#T_POR)         ' wait _before_ bus activity
                if okay := i2c.setupx(SCL_PIN, SDA_PIN, I2C_HZ)
                    _addr_bits := ADDR_BITS << 1
                    if i2c.present(SLAVE_WR | _addr_bits)
                        defaults{}
                        _disp_width := width
                        _disp_height := height
                        _disp_xmax := _disp_width-1
                        _disp_ymax := _disp_height-1
                        _buff_sz := (_disp_width * _disp_height) / 8
                        BYTESPERLN := _disp_width * BYTESPERPX

                        address(ptr_disp)

                        return okay
    return FALSE                                ' something above failed

PUB Stop{}

    powered(FALSE)
    oscenabled(FALSE)
    time.msleep(100)
    i2c.terminate

PUB Defaults{}

    oscenabled(TRUE)
    brightness(15)
    powered(TRUE)

PUB Address(addr): curr_addr
' Set framebuffer address
    case addr
        $0004..$7FFF-_buff_sz:
            _ptr_drawbuffer := addr
            return _ptr_drawbuffer
        other:
            return _ptr_drawbuffer

PUB BlinkRate(rate_hz)
' Set blink rate of display, in Hz
'   Valid values: 0.5, 5, 1, 2
'   Any other value disables blinking
    case rate_hz
        2:      _blink_freq := %01 << 1
        1:      _blink_freq := %10 << 1
        0.5, 5: _blink_freq := %11 << 1
        other:  _blink_freq := %00 << 1

    writereg(core#CMD_DISPSETUP, _blink_freq | _disp_power)

PUB Brightness(level)
' Set display brightness
'   Valid values: 0..15
'   Any other value is ignored
    case level
        0..15:
        other:
            return
    writereg(core#CMD_BRIGHTNESS, level)

PUB ClearAccel{}
' Dummy method

PUB OscEnabled(state)
' Enable the oscillator
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value is ignored
    case ||(state)
        0, 1: state := ||(state)
        other:
            return
    writereg(core#CMD_OSCILLATOR, state)

PUB Powered(state)
' Power on display
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value is ignored
    case ||(state)
        0, 1: _disp_power := ||(state)
        other:
            return

    writereg(core#CMD_DISPSETUP, _blink_freq | _disp_power)

PUB Update{}
' Write display buffer to display
    writereg(core#DISP_RAM, _ptr_drawbuffer)

PRI writeReg(reg, ptr_buff) | cmd_packet[2], i
' Write reg to device from ptr_buff
    cmd_packet.byte[0] := SLAVE_WR | _addr_bits

    case reg
        core#DISP_RAM:                          ' Display RAM
            cmd_packet.byte[1] := core#DISP_RAM
            i2c.start{}
            i2c.wr_block(@cmd_packet, 2)
            repeat i from 0 to 7
                i2c.write((byte[ptr_buff][i]) & $FF)
                i2c.write($00)
            i2c.stop{}

        core#CMD_OSCILLATOR, core#CMD_DISPSETUP, core#CMD_ROWINT, {
        } core#CMD_BRIGHTNESS:                  ' Control registers
            cmd_packet.byte[1] := reg | ptr_buff
            i2c.start{}
            i2c.wr_block(@cmd_packet, 2)
            i2c.stop{}
        other:
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
