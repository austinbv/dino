#
# Example driving a stepper motor with the EasyDriver board: https://www.sparkfun.com/products/10267?
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)
stepper = Dino::Components::Stepper.new(board: board, pins: { step: 10, direction: 8 })

1600.times do
  stepper.step_cc
  sleep 0.001
end

1600.times do
  stepper.step_cw
  sleep 0.001
end

# The board writes asynchronously. Make sure it has written everything before we exit.
board.finish_write
