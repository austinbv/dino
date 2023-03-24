#
# Example using an SSD1306 driven OLED screen over I2C.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)

#
# Default pins for the I2C0 (first) interface on most chips:
#
# ATmega 328p:       SDA = 'A4'  SCL = 'A5' - Arduino Uno, Nano
# ATmega 32u4:       SDA =   2   SCL =   3  - Arduino Leonardo, Pro Micro
# ATmega1280 / 2560: SDA =  20   SCL =  21  - Arduino Mega
# SAM3X8E:           SDA =  20   SCL =  21  - Arduino Due
# SAMD21G18:         SDA =  20   SCL =  21  - Arduino Zero, M0, M0 Pro
# ESP8266:           SDA =   4   SCL =   5
# ESP32:             SDA =  21   SCL =  22
# RP2040:            SDA =   4   SCL =   5  - Raspberry Pi Pico (W)
#
# Only give the SDA pin of the I2C bus. SCL (clock) pin must be 
# connected for it to work, but we don't need to control it.
#
bus = Dino::Components::I2C::Bus.new(board: board, pin: 'A4')

oled = Dino::Components::I2C::SSD1306.new(bus: bus, address: 0x3C)

oled.print("Hello World!")

board.finish_write
