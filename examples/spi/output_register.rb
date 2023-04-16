#
# Example of an LED connected through an output shift register (74HC595).
# Can be used over either a bit bang or hardware SPI interface.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::Board::Connection::Serial.new)

# Create a 1-way bit bang SPI interface on any pins (slower, but flexible).
bus = Dino::SPI::BitBang.new(board: board, pins: { clock: 13, input: 11 })

# Or use the default hardware SPI interface on its predefined pins (fast).
# bus = Dino::SPI::Bus.new(board: board)

# Output register needs a bus and a pin (its latch / select pin).
register = Dino::SPI::OutputRegister.new  bus: bus,
                                          pin: 10
                                          # bit_order: :msbfirst
                                          # frequency: 1000000
                                          # spi_mode: 0
                                          # bytes: 1
                                          # buffer_writes: true

# Write a single byte
register.write(255)

# Write an array of bytes (for multiple registers).
register.write([255, 0])

#
# OutputRegister includes BoardProxy behavior, so some components can use it as a board.
#
# Blink an LED connected to register output pin 0.
led = Dino::LED.new(board: register, pin: 0)
led.blink 0.5

sleep
