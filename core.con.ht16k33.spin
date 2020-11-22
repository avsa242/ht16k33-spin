{
    --------------------------------------------
    Filename: core.con.ht16k33.spin
    Description: Low-level constants
    Author: Jesse Burt
    Created Oct 9, 2018
    Updated Nov 22, 2020
    Copyright (c) 2020
    See end of file for terms of use.
    --------------------------------------------
}

CON

    SLAVE_ADDR      = $70 << 1
    I2C_MAX_FREQ    = 400_000

    T_POR           = 1_000                     ' usec

' Registers/commands
    DISP_RAM        = $00                       ' Start of display RAM

    CMD_OSCILLATOR  = $20                       ' command is upper nibble
    CMD_DISPSETUP   = $80                       '   parameter is OR'd with it
    CMD_ROWINT      = $A0
    CMD_BRIGHTNESS  = $E0
    CMD_TESTMODE    = $D9

PUB Null{}
' This is not a top-level object

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
