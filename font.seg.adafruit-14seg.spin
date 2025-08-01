{
---------------------------------------------------------------------------------------------------
    Filename:       font.seg.adafruit-14seg.spin
    Description:    14-segment display font - Adafruit 4-digit displays
    Author:         Jesse Burt
    Started:        Jul 26, 2025
    Updated:        Aug 1, 2025
    Copyright (c) 2025 - See end of file for terms of use.
---------------------------------------------------------------------------------------------------
}

pub setup(): p
' Get pointer to font definition
    return @font_def


dat

    font_def
    firstchar   byte    32
    lastchar    byte    127
    colon_pos   byte    0                       ' which "digit" of the display
    reserved    byte    0

    ' define mappings to individual display segments
    ' glyphs defined as just '0' are essentially not supported - this wastes a bit of RAM,
    '   but as a tradeoff, keeps the putchar() routine simpler
    table
        word    %0000_0000_0000_0000    ' (SP) - 32/$20
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

