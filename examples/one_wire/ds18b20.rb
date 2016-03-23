#
# Example of how to use the Dallas DS18B20 temperature sensor.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)

# The temperature and humidity functions of the DHT sensors are
# modelled separately, but both isntances can be set up on the same pin.
temp = Dino::Components::DS18B20.new(pin: 7, board: board)

temp.read do |temperature|
  puts "The temperature is #{temperature} degrees C"
end
