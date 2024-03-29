{
---------------------------------------------------------------------------------------------------
    Filename:       display.led.ht16k33.spin
    Description:    Driver for HT16K33-based LED displays (matrix type)
    Author:         Jesse Burt
    Started:        Oct 11, 2018
    Updated:        Jan 28, 2024
    Copyright (c) 2024 - See end of file for terms of use.
---------------------------------------------------------------------------------------------------
}

#define 1BPP
#define MEMMV_NATIVE bytemove
#include "ht16k33.common.spinh"
#include "graphics.common.spinh"
#ifdef GFX_DIRECT
#   error "GFX_DIRECT not supported by this driver"
#endif

CON

    MAX_COLOR   = 1
    BYTESPERPX  = 1

    { default I/O settings; these can be overridden in the parent object }
    SCL         = DEF_SCL
    SDA         = DEF_SDA
    I2C_FREQ    = DEF_HZ
    I2C_ADDR    = DEF_ADDR

    WIDTH       = 8
    HEIGHT      = 8
    BUFFSZ      = (WIDTH * HEIGHT) / 8
    XMAX        = WIDTH-1
    YMAX        = HEIGHT-1

VAR

    byte _framebuffer[BUFFSZ]

PUB start{}: status
' Start using default I/O settings
    return startx(SCL, SDA, I2C_FREQ, I2C_ADDR, WIDTH, HEIGHT, @_framebuffer)

PUB startx(SCL_PIN, SDA_PIN, I2C_HZ, ADDR_BITS, DISP_W, DISP_H, ptr_dispbuff=0): status
' width, height: dimensions of matrix, in pixels
' SCL_PIN, SDA_PIN, I2C_HZ: I2C bus I/O pins and speed
' ADDR_BITS: specify LSBs of slave address (%000..%111)
' ptr_disp: pointer to display buffer, of minimum (W*H)/8 bytes
'   (e.g., for an 8x8 matrix, 8*8=64 / 8 = 8 bytes)
'   omit or specify 0 to use the internal framebuffer
    if ( lookdown(SCL_PIN: 0..31) and lookdown(SDA_PIN: 0..31) )
        if ( lookdown(ADDR_BITS: %000..%111) )
            if ( status := i2c.init(SCL_PIN, SDA_PIN, I2C_HZ) )
                time.usleep(core#T_POR)         ' wait for device startup
                _addr_bits := ADDR_BITS << 1
                if ( i2c.present(SLAVE_WR | _addr_bits) )' test device presence
                    set_dims(DISP_W, DISP_H)
                    set_address(ptr_dispbuff)

                    return
    ' if this point is reached, something above failed
    ' Double check I/O pin assignments, connections, power
    ' Lastly - make sure you have at least one free core/cog
    return FALSE

#ifndef GFX_DIRECT
PUB clear{}
' Clear the display buffer
    bytefill(_ptr_drawbuffer, _bgcolor, _buff_sz)
#endif

PUB plot(x, y, color)
' Plot pixel at (x, y) in color
    if ((x < 0 or x > _disp_xmax) or (y < 0 or y > _disp_ymax))
        return                                  ' coords out of bounds, ignore
#ifdef GFX_DIRECT
' direct to display
'   (not implemented)
#else
' buffered display
    x := x + 7
    x := x // 8

    case color
        1:
            byte[_ptr_drawbuffer][y] |= |< x
        0:
            byte[_ptr_drawbuffer][y] &= !(|< x)
        -1:
            byte[_ptr_drawbuffer][y] ^= |< x
        other:
            return
#endif

#ifndef GFX_DIRECT
PUB point(x, y): pix_clr
' Get color of pixel at x, y
    x := 0 #> x <# _disp_xmax
    y := 0 #> y <# _disp_ymax

    x := x + 7
    x := x // 8
    return byte[_ptr_drawbuffer][y + (x >> 3) * _disp_width]
#endif

PUB show{}
' Write display buffer to display
    writereg(core#DISP_RAM, _ptr_drawbuffer)

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

