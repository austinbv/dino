#
# This is an example of how to use the sensor class
# You must register data callbacks and have the main thread
# sleep or in someway keep running or your program
# will exit before any callbacks can be called
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)
sensor = Dino::Components::Sensor.new(pin: 'A0', board: board)

sensor.when_data_received do |data|
  puts data
end

sleep
