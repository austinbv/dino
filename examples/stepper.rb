#
# This is a simple example to move a stepper motor using the sparkfun easydriver shield: https://www.sparkfun.com/products/10267?
#

require '../lib/dino'

board = Dino::Board.new(Dino::TxRx.new)
stepper = Dino::Components::Stepper.new(board: board)

1600.times do
  stepper.step_cc
  sleep 0.001
end

1600.times do
  stepper.step_cw
  sleep 0.001
end

