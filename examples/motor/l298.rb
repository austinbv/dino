#
# Example driving a DC motor with a L298 H-Bridge driver.
#
require 'bundler/setup'
require 'dino'
board = Dino::Board.new(Dino::Connection::Serial.new)

# This is only 1 channel of the driver. Make a new object for each channel.
motor = Dino::Motor::L298.new board: board, pins: {direction1: 8, direction2: 9, enable: 10}

# Off without braking (initial state).
# motor.off
# motor.idle

# Go forward at half speed for a while.
motor.forward board.pwm_high / 2
sleep 2

# Change direction.
motor.reverse board.pwm_high / 2
sleep 2

# Speed up without changing direction.
motor.speed = board.pwm_high
sleep 2

# Brake to stop quickly.
motor.brake
sleep 1

# Change from brake to forward, but 0 speed.
motor.forward 0
sleep 1

# Gradually speed up.
(1..20).each do |step|
  sleep 0.5
  motor.speed = (board.pwm_high * (step / 20.0)).round
end

# Turn it off.
motor.off
board.finish_write
