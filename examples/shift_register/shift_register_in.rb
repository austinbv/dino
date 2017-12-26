#
# This is a simple example to write to a shift register.
# Writing a byte of 255 sets all the output pins to high.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)
shift_register = Dino::Components::ShiftRegisterIn.new(bytes: 1, clock_high_first: true, pins: {data: 14, latch: 15, clock: 16}, board: board)

button = Dino::Components::Button.new(pin: 7, board: shift_register)

button.down { puts "down"}
button.up   { puts "up"  }

loop do
  button.read
  sleep 0.1
end
