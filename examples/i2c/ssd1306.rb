#
# Basic example of printing text to a SSD1306 driven OLED screen,
# connected over the I2C interface.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)

# Only pass the SDA pin of the I2C bus. SCL (clock) pin must be 
# connected for it to work, but we don't need to control it.
#
# Arduino Uno:        SDA = 'A4'   SCL = 'A5'
# Leonardo:           SDA =   2    SCL =   3
# Due / Mega / Zero:  SDA =  20    SCL =  21
# ESP8266 :           SDA =   4    SCL =   5
# ESP32:              SDA =  21    SCL =  22
#
# On the ESP8266, 'D2' and 'D1' also map to SDA and SCL respectively.
# This is for convenience when working with common development boards.
#
bus = Dino::Components::I2C::Bus.new(board: board, pin: 20)

oled = Dino::Components::I2C::SSD1306.new(bus: bus, address: 0x3C)

oled.print("Hello World!")

board.finish_write
