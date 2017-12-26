#
# This is a simple example to write to a shift register.
# Writing a byte of 255 sets all the output pins to high.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)
shift_register = Dino::Components::ShiftRegisterOut.new(pins: {data: 11, latch: 8, clock: 12}, board: board)

# Write a single byte
shift_register.write(255)

# Write an array of bytes (for multiple registers).
shift_register.write([255, 0])

sleep
