#
# Example using AHT21 sensor over I2C, for temperature and humidity.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::Connection::Serial.new)
bus = Dino::I2C::Bus.new(board: board, pin: :SDA)
aht20 = Dino::Sensor::AHT20.new(bus: bus)

aht20.poll(2) do |reading|
  puts "Polled Reading: #{reading[:temperature].round(3)} \xC2\xB0C | #{reading[:humidity].round(3)} % RH"
end

sleep
