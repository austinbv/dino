#
# Example using the Arduino shiftIn function to read data from a shift register.
# SPI is more efficient and may work with the same hardware, so use that if possible.
# See examples/spi_in.rb
#
# The register is a BoardProxy, and implements enough Board methods that
# DigitalInput components can use its pins directly.
#
# The Button object is created by using the register in place of board, and
# the register output pin that it's connected to.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)

shift_register = Dino::Components::Register::ShiftIn.new  board: board,
                                                          pins: {latch: 10, data: 12, clock: 13},
                                                          rising_clock: true,
                                                          bytes: 1

button = Dino::Components::Button.new(pin: 0, board: shift_register)

button.down { puts "down"}
button.up   { puts "up"  }

# Force callbacks to run at least once for the initial state.
button.read

sleep
