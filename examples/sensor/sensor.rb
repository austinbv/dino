#
# This is an example of how to use the sensor class
# You must register data callbacks and have the main thread
# sleep or in someway keep running or your program
# will exit before any callbacks can be called
#
require 'bundler/setup'
require 'smalrubot'

board = Smalrubot::Board.new(Smalrubot::TxRx::Serial.new)
sensor = Smalrubot::Components::Sensor.new(pin: 'A0', board: board)

sensor.when_data_received do |data|
  puts data
end

sleep
