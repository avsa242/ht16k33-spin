{
---------------------------------------------------------------------------------------------------
    Filename:       display.led-seg.ht16k33.spin
    Description:    Driver for HT16K33-based LED displays (segment type)
    Author:         Jesse Burt
    Started:        Jun 22, 2021
    Updated:        Aug 1, 2025
    Copyright (c) 2025 - See end of file for terms of use.
---------------------------------------------------------------------------------------------------
}

#include "ht16k33.common.spinh"
#include "terminal.common.spinh"

CON

    { default I/O settings; these can be overridden in the parent object }
    SCL             = 28
    SDA             = 29
    I2C_FREQ        = 100_000
    I2C_ADDR        = %000

    WIDTH           = 4
    HEIGHT          = 1

    BUFF_SZ         = (WIDTH*HEIGHT)+1
    BUFF_SZ_BYTES   = BUFF_SZ*2


VAR

    long _font_addr

    long _disp_width, _disp_height, _disp_xmax, _disp_ymax
    word _disp_buff[BUFF_SZ]
    byte _lastdigit, _font_cmin, _font_cmax, _colon_pos
    byte _wr_ptr


PUB start(): status
' Start using default I/O settings
    return startx(SCL, SDA, I2C_FREQ, I2C_ADDR, WIDTH, HEIGHT)


PUB startx(SCL_PIN, SDA_PIN, I2C_HZ, ADDR_BITS, DISP_W, DISP_H): status
' SCL_PIN, SDA_PIN, I2C_HZ: I2C bus I/O pins and speed
' ADDR_BITS: specify LSBs of slave address (%000..%111)
' DISP_W, DISP_H: dimensions of display, in digits/characters
    if ( lookdown(SCL_PIN: 0..31) and lookdown(SDA_PIN: 0..31) and ...
        lookdown(ADDR_BITS: %000..%111) )
        if ( status := i2c.init(SCL_PIN, SDA_PIN, I2C_HZ) )
            time.usleep(core.T_POR)             ' wait for device startup
            _addr_bits := ADDR_BITS << 1
            _disp_width := DISP_W
            _disp_height := DISP_H
            _disp_xmax := WIDTH-1
            _disp_ymax := HEIGHT-1
            if ( i2c.present(SLAVE_WR | _addr_bits) ) ' test device presence
                clear()
                return
    ' if this point is reached, something above failed
    ' Double check I/O pin assignments, connections, power
    ' Lastly - make sure you have at least one free core/cog
    return FALSE


PUB clear()
' Clear display
    wordfill(@_disp_buff, 0, BUFF_SZ)
    pos_xy(0, 0)


PUB move_left()
' Move cursor left one column
'   NOTE: Wraps around to the last column
    _wr_ptr--
    if ( _wr_ptr < 0 )
        _wr_ptr := BUFF_SZ-1


PUB move_right()
' Move cursor right one column
'   NOTE: Wraps around to the first column
    _wr_ptr++
    if ( _wr_ptr > _disp_xmax )
        _wr_ptr := 0


PUB position = pos_xy
PUB pos_xy(x, y)
' Set cursor position
    if ( (x => 0) and (x =< _disp_xmax) and (y => 0) and (y =< _disp_ymax) )
        _wr_ptr := (y * _disp_width) + x


PUB positionx = pos_x
PUB pos_x(x)
' Set cursor X position
    if ( (x => 0) and (x =< _disp_xmax) )
        _wr_ptr := x


PUB positiony = pos_y
PUB pos_y(y)
' Set cursor Y position
    if ( (y => 0) and (y =< _disp_ymax) )
        _wr_ptr := (y * _disp_width)


PUB char = putchar
PUB putchar(ch) | cmd_pkt, i
' Write character to display
'   NOTE: Interprets control characters
    case ch
        BS, DEL:                                ' backspace/delete
            _wr_ptr := (_wr_ptr-1)
            _wr_ptr := _wr_ptr <# (BUFF_SZ-1)
            _disp_buff[_wr_ptr] := 0
        FF:
            clear()
        CR:
            pos_x(0)
        ".":                                    ' draw a dot in the pos of the last digit drawn to
            _disp_buff[_lastdigit] |= word[_font_addr][ch-_font_cmin]
            return
        _font_cmin.._font_cmax:
            if ( ch == ":" )
                if ( _colon_pos > 0 )
                    _disp_buff[_colon_pos] := word[_font_addr][":"-_font_cmin]
                    return
                else
                    _disp_buff[_wr_ptr] |= word[_font_addr][ch-_font_cmin]
                    _wr_ptr++
            else
                _lastdigit := _wr_ptr           ' note this position so the next dot is drawn here
                _disp_buff[_wr_ptr] := word[_font_addr][ch-_font_cmin]
                _wr_ptr++
        other:
            return

    if ( (_wr_ptr == _colon_pos) and ( _colon_pos > 0 ) )
        ' we only get here if the character drawn wasn't a colon and the font doesn't have
        '   a dedicated colon "pixel" defined
        _disp_buff[_colon_pos] := 0
        _wr_ptr++

    if ( _wr_ptr > _disp_xmax )                 ' wrap-around buffer
        _wr_ptr := 0


PUB set_font(p_fnt)
' Set up a font
'   p_fnt:  pointer to font glyph/segment-mapping data base
    _font_addr := p_fnt+4                       ' get segment mapping base pointer
    bytemove(@_font_cmin, p_fnt, 3)             ' read min/max chars, colon digit position


PUB show() | cmd_pkt, i, w
' Write the display buffer to the display
    cmd_pkt.byte[0] := SLAVE_WR | _addr_bits
    cmd_pkt.byte[1] := core.DISP_RAM
    i2c.start()
    i2c.wrblock_lsbf(@cmd_pkt, 2)
    i2c.wrblock_lsbf(@_disp_buff, BUFF_SZ*2)
    i2c.stop()


DAT
{
Copyright 2025 Jesse Burt

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

