#
# Example showing how to set up an output shift register.
# Multiple bytes may be written in one operation.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)
shift_register = Dino::Components::Register::ShiftOut.new  board: board,
                                                           pins: {latch: 9, data: 11, clock: 13}

# Write a single byte
shift_register.write(255)

# Write an array of bytes (for multiple registers).
shift_register.write([255, 0])

sleep
