#
# This is an example of how to use the servo class
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)
sensor = Dino::Components::HCSR04.new(pin: 9, board: board)

sensor.read do |reading|
  puts reading
end
