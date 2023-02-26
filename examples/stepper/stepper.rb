#
# Example driving a stepper motor with the EasyDriver board: https://www.sparkfun.com/products/10267?
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)
stepper = Dino::Components::Stepper.new board: board,
                                        pins: { slp: 6, enable: 7, direction: 8, step: 10, ms1: 11, ms2: 12 }
                                        
# Default is 8 microsteps. Set to 2 so we can move faster.
stepper.microsteps = 2

# 400 steps is now 1 revolution for a 200 step motor.
400.times do
  stepper.step_cc
  sleep 0.002
end

# Sleep the driver chip and wait a while.
stepper.sleep
sleep 1

# Wake it up and set to full steps. 
stepper.wake
stepper.microsteps = 1

#
# Now 200 steps the other way will move us back to the start.
# Note the longer sleep here since the steps are bigger.
# Adjust both sleep vales to suit your motor.
#
200.times do
  stepper.step_cw
  sleep 0.006
end

# Sleep the driver once we're done.
stepper.sleep

# We write to the board asynchronously.
# Make sure we send all step commands before exit.
board.finish_write
