#
# Example showing how to read an input shift register using Arduino's "shiftIn".
#
# The register implements #digital_read and other methods expected by Components,
# and makes its parallel pins addressable (zero index), so it can proxy the Board class.
#
# The Button object is created by passing the register instead of the board, and
# the register's parallel output pin that the button is connected to.
#
# Note: preclock_high must be set to true if using TI CD4021B register or similar.
# This should apply to any register which outputs on a rising clock edge.
# Change as needed.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)

shift_register = Dino::Components::Register::ShiftIn.new  board: board,
                                                          pins: {latch: 10, data: 12, clock: 13},
                                                          preclock_high: true,
                                                          bytes: 1

button = Dino::Components::Button.new(pin: 0, board: shift_register)

button.down { puts "down"}
button.up   { puts "up"  }

loop do
  button.read
  sleep 0.1
end
