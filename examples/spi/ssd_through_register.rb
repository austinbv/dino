#
# Example using an output sfhit register (74HC595) to drive a seven segment display.
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
                                        
#
# The register is a BoardProxy, and implements enough Board methods that
# DigitalOutputs can use its pins directly.
#
# ssd is created by using the register in place of board, and
# the register output pins connected to the SevenSegment LED.
#
ssd = Dino::LED::SevenSegment.new board: register,
                                  pins:  { cathode: 0, a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7 }

# Turn off the ssd on exit
trap("SIGINT") { exit !ssd.off }

# Display each new line on the ssd
loop { ssd.display(gets.chomp) }
