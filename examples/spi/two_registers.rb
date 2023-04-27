#
# Example of 2 SPI devices on the same bus with different select pins.
# Combination of input_register.rb and output_register.rb
#
require 'bundler/setup'
require 'dino'

# SPI pins (on board)
SPI_BIT_BANG_PINS   = { clock: 13, input: 12, output: 11 }
OUT_REGISTER_SELECT = 10
IN_REGISTER_SELECT  = 9

# LED and Button pins (on their respective registers' parallel pins)
LED_PIN     = 0
BUTTON_PIN  = 0

board = Dino::Board.new(Dino::Connection::Serial.new)

# 2-way bit bang SPI bus (slower, but use any pins).
bus = Dino::SPI::BitBang.new(board: board, pins: SPI_BIT_BANG_PINS)

# Use the default hardware SPI bus (faster, but predetermined pins).
# bus = Dino::SPI::Bus.new(board: board)

# Show the hardware SPI pins to aid connection.
# MOSI = output | MISO = input | SCK = clock
# puts board.map.select { |name, number| [:MOSI, :MISO, :SCK].include?(name) }

# OutputRegister needs a bus and its select pin.
out_register = Dino::SPI::OutputRegister.new(bus: bus, pin: OUT_REGISTER_SELECT)

# InputRegister needs a bus and its select pin. The CD4021 likes SPI mode 2.
in_register = Dino::SPI::InputRegister.new(bus: bus, pin: IN_REGISTER_SELECT, spi_mode: 2)

# LED connected to the output register.
led = Dino::LED.new(board: out_register, pin: LED_PIN)                                 

# Button connected to the input register.
button = Dino::DigitalIO::Button.new(board: in_register, pin: BUTTON_PIN)

# Button callbacks.
button.down { led.on;  puts "Button pressed"  }
button.up   { led.off; puts "Button released" }

# Sleep the main thread. Press the button and callbacks will run.
sleep
