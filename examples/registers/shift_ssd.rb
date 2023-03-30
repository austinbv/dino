#
# Example using the Arduino shiftOut function to drive a seven segment display.
# SPI is more efficient and may work with the same hardware, so use that if possible.
# See examples/spi_ssd.rb
#
# The register is a BoardProxy, and implements enough Board methods that
# DigitalOutput components can use its pins directly.
#
# The SSD object is created by using the register in place of board, and
# the register output pins that the SSD is connected to.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::Board::Connection::Serial.new)
shift_register = Dino::Register::ShiftOutput.new  board: board,
                                                  pins: {latch: 9, data: 11, clock: 12}
                                                  # bit_order: :msbfirst
                                                  # bytes: 1
                                                  # buffer_writes: true

ssd = Dino::LED::SevenSegment.new board: shift_register,
                                  pins:  { cathode: 0, a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7 }

# Turn off the ssd on exit
trap("SIGINT") { exit !ssd.off }

# Display each new line on the ssd
loop { ssd.display(gets.chomp) }