#
# Example of SevenSegment LED driven though an output shift register (74HC595).
# Can be used on either a bit bang or hardware SPI interface.
#
require 'bundler/setup'
require 'dino'

# SPI pins (on board)
SPI_BIT_BANG_PINS   = { clock: 13, output: 11 }
REGISTER_SELECT_PIN = 10

# SevenSegment pins (on register parallel outputs)
SEVEN_SEGMENT_PINS = { cathode: 0, a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7 }

board = Dino::Board.new(Dino::Board::Connection::Serial.new)

# 1-way bit bang SPI bus (slower, but use any pins).
bus = Dino::SPI::BitBang.new(board: board, pins: SPI_BIT_BANG_PINS)

# Use the default hardware SPI bus (faster, but predetermined pins).
# bus = Dino::SPI::Bus.new(board: board)

# Show the hardware SPI pins to aid connection.
# MOSI = output | MISO = input | SCK = clock
# puts board.map.select { |name, number| [:MOSI, :MISO, :SCK].include?(name) }

# OutputRegister needs a bus and its select pin.
register = Dino::SPI::OutputRegister.new(bus: bus, pin: REGISTER_SELECT_PIN)

#
# OutputRegister implements enough of the Board interface that digital output
# components can treat it as a Board. Do that with the SSD.
#
ssd = Dino::LED::SevenSegment.new(board: register, pins: SEVEN_SEGMENT_PINS)

# Turn off the ssd on exit.
trap("SIGINT") { exit !ssd.off }

# Type a character and press Enter to show it on the SevenSegment LED.
loop { ssd.display(gets.chomp) }
