#
# This is a simple example to move a stepper motor using the sparkfun easydriver shield: https://www.sparkfun.com/products/10267?
#
require 'bundler/setup'
require 'smalrubot'

board = Smalrubot::Board.new(Smalrubot::TxRx::Serial.new)
stepper = Smalrubot::Components::Stepper.new(board: board, pins: { step: 10, direction: 8 })

  1600.times do
    stepper.step_cc
    sleep 0.001
  end

  1600.times do
    stepper.step_cw
    sleep 0.001
  end
