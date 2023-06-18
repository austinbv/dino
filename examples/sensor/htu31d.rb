#
# Example using HTU31D sensor over I2C, for temperature and humidity.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::Connection::Serial.new)
bus = Dino::I2C::Bus.new(board: board, pin: :SDA)
htu31d = Dino::Sensor::HTU31D.new(bus: bus)

# Get and set heater state.
htu31d.heater_on
puts "Heater on: #{htu31d.heater_on?}"
htu31d.heater_off
puts "Heater off: #{htu31d.heater_off?}"

# Back to default settings, including heater off, unlike HTU21D.
htu31d.reset
puts "Resetting HTU31D... Heater off: #{htu31d.heater_off?}"
puts

# Resolution goes from 0..3 separately for temperature and humidity. See datasheet.
htu31d.temperature_resolution = 3
htu31d.humidity_resolution = 3

# Unlike HTU21D, HTU31D works as a regular polled sensor.
htu31d.poll(2) do |reading|
  puts "Polled Reading: #{reading[:temperature].round(3)} \xC2\xB0C | #{reading[:humidity].round(3)} % RH"
end

sleep
