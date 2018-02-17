#
# Example showing how to set up an output shift register.
# Multiple bytes may be written in one operation.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)
register = Dino::Components::Register::ShiftOut.new  board: board,
                                                     pins: {latch: 9, data: 11, clock: 13}

# Write a single byte
register.write(255)

# Write an array of bytes (for multiple registers).
register.write([255, 0])

# Register can behave as a BoardProxy, with components addressable directly.
led = Dino::Components::Led.new(board: register, pin: 0)
led.blink 1

sleep
