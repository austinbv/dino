#
# Example of LED connected through an output shift register (74HC595).
# Can be used over either a bit bang or hardware SPI interface.
#
require 'bundler/setup'
require 'dino'

# SPI pins (on board)
SPI_BIT_BANG_PINS   = { clock: 13, output: 11 }
REGISTER_SELECT_PIN = 10

# LED pin (on register parallel outputs)
LED_PIN = 0

board = Dino::Board.new(Dino::Board::Connection::Serial.new)

# 1-way (output) bit bang SPI interface on any pins (slower, but flexible).
bus = Dino::SPI::BitBang.new(board: board, pins: SPI_BIT_BANG_PINS)

# Use the default hardware SPI bus (faster, but predetermined pins).
# bus = Dino::SPI::Bus.new(board: board)

# Show the hardware SPI pins to aid connection.
# MOSI = output | MISO = input | SCK = clock
# puts board.map.select { |name, number| [:MOSI, :MISO, :SCK].include?(name) }

# OutputRegister needs a bus and its select pin.
# Other options and their defaults:
#     bit_order:      :msbfirst
#     spi_frequency:  1000000    - Only affects hardware SPI interfaces
#     spi_mode:       0
#     bytes:          1          - For daisy-chaining registers
#     write_delay:    0.001      - How long to buffer writes, in seconds
#     buffer_writes:  true       - Wait for write_delay before writing whole register state.
#                                  Makes proxied components write pseudo-parallelly.
#
register = Dino::SPI::OutputRegister.new(bus: bus, pin: REGISTER_SELECT_PIN)

# We can turn the LED on by writing a 1 to the lowest bit (0) of the register.
register.write(0b00000001)

# OutputRegister implements enough of the Board interface that digital output
# components can treat it as a Board. Do that with the LED instead.
#
led = Dino::LED.new(board: register, pin: 0)

# Blink the LED and sleep the main thread.
led.blink 0.5
sleep
