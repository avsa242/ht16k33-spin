{
    --------------------------------------------
    Filename: display.led.ht16k33.i2c.spin
    Author: Jesse Burt
    Created: Oct 11, 2018
    Updated: Oct 11, 2018
    Copyright (c) 2018
    See end of file for terms of use.
    --------------------------------------------
}

CON

  SLAVE_ADDR    = ht16k33#SLAVE_ADDR
  SLAVE_ADDR_W  = SLAVE_ADDR
  SLAVE_ADDR_R  = SLAVE_ADDR|1
  
  DEF_SCL       = 28
  DEF_SDA       = 29
  DEF_HZ        = ht16k33#I2C_DEF_FREQ

VAR

  byte _disp_power, _blink_freq, _disp_buff[8]

OBJ

  i2c     : "jm_i2c_fast"
  ht16k33 : "core.con.ht16k33"
  debug   : "debug"
  time    : "time"

PUB null
''This is not a top-level object

PUB Start: okay                                         'Default to "standard" Propeller I2C pins and 400kHz

  okay := Startx (DEF_SCL, DEF_SDA, DEF_HZ)

PUB Startx(SCL_PIN, SDA_PIN, I2C_HZ): okay

    if lookdown(SCL_PIN: 0..31) and lookdown(SDA_PIN: 0..31)
        if I2C_HZ =< ht16k33#I2C_MAX_FREQ
            okay := i2c.setupx (SCL_PIN, SDA_PIN, I2C_HZ)
            time.USleep (100)
            Oscillator (TRUE)
            Display (TRUE)
            return okay
        else
          return FALSE
    else
    return FALSE


PUB Oscillator(enabled)

  case ||enabled
    0, 1: enabled := ||enabled
    OTHER:
        return
  cmd (ht16k33#CMD_OSCILLATOR | enabled)

PUB Display(enabled)

    case ||enabled
        0, 1: _disp_power := ||enabled
        OTHER:
            return
    cmd (ht16k33#CMD_DISPSETUP | _blink_freq | _disp_power)

PUB SetBlinkRate(rate_hz)

  case rate_hz
    2:      _blink_freq := %01 << 1
    1:      _blink_freq := %10 << 1
    0.5, 5: _blink_freq := %11 << 1
    OTHER:  _blink_freq := %00 << 1

  cmd (ht16k33#CMD_DISPSETUP | _blink_freq | _disp_power)

PUB SetBrightness(level)

  case level
    0..15:
    OTHER:  level := %1111

  cmd (ht16k33#CMD_BRIGHTNESS | level)

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


 '   _disp_buff[y] |= 1 << x
    WriteBuff

PUB WriteChar | i

    repeat i from 0 to 7
        _disp_buff[i] |= ch0[i]

    WriteBuff

PUB WriteBuff | i

    i2c.start
    i2c.write (SLAVE_ADDR_W)
    i2c.write ($00)

    repeat i from 0 to 7
        i2c.write ((_disp_buff[i]) & $FF)
        i2c.write ((_disp_buff[i]) >> 8)
    i2c.stop

PUB getaddr

    return @_disp_buff

DAT

    ch0 byte    %10011001
        byte    %00100100
        byte    %01000010
        byte    %01001010
        byte    %01010010
        byte    %01000010
        byte    %00100100
        byte    %00011000

PUB cmd(cmd_byte)

  i2c.start
  i2c.write (SLAVE_ADDR_W)
  i2c.write (cmd_byte)
  i2c.stop

PUB readOne: readbyte

  readX (@readbyte, 1)

PUB readX(ptr_buff, num_bytes)

  i2c.start
  i2c.write (SLAVE_ADDR_R)
  i2c.pread (ptr_buff, num_bytes, TRUE)
  i2c.stop

PUB writeOne(data)

  WriteX (data, 1)

PUB WriteX(ptr_buff, num_bytes)

  i2c.start
  i2c.write (SLAVE_ADDR_W)
  i2c.pwrite (ptr_buff, num_bytes)
  i2c.stop

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
