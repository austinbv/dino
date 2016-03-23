#
# Example of how to use the DHT class for DHT 11 and DHT 22 sensors.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)

# The temperature and humidity functions of the DHT sensors are
# modelled separately, but both isntances can be set up on the same pin.
temp = Dino::Components::DHT::Temperature.new(pin: 4, board: board)
humidity = Dino::Components::DHT::Humidity.new(pin: 4, board: board)

temp.read do |temperature|
  puts "The temperature is #{temperature} degrees C"
end

humidity.read do |humidity|
  puts "The relative humidity is #{humidity}%"
end
