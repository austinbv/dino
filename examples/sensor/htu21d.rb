#
# Example using HTU21D sensor over I2C, for temperature and humidity.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::Connection::Serial.new)
bus = Dino::I2C::Bus.new(board: board, pin: :SDA)
htu21d = Dino::Sensor::HTU21D.new(bus: bus)

# Get and set heater state.
htu21d.heater_on
puts "Heater on: #{htu21d.heater_on?}"
htu21d.heater_off
puts "Heater off: #{htu21d.heater_off?}"
puts

# Back to default settings, except heater state.
htu21d.reset

# Only 4 resolution combinations are available, and need to be
# set by giving a bitmask from the datasheet:
#   0x00 = 14-bit temperature, 12-bit humidity
#   0x01 = 12-bit temperature,  8-bit humidity (default)
#   0x80 = 13-bit temperature, 10-bit humidity
#   0x81 = 11-bit temperature, 11-bit humidity
#
htu21d.resolution = 0x81
puts "Temperature resolution: #{htu21d.resolution[:temperature]} bits"
puts "Humidity resolution:    #{htu21d.resolution[:humidity]} bits"
puts

# Take direct readings by calling methods on the HTU21D instance.
#   Note: These methods do not take block callbacks like other components.
#         The HTU21D class doesn't directly implement polling methods either.
#
puts "Direct Temperature: #{htu21d.read_temperature.round(3)} \xC2\xB0C"
puts "Direct Humidity:    #{htu21d.read_humidity.round(3)} %"
puts

# The last read state can be accessed through sub-objects or [].
puts "Last Temperature: #{htu21d.temperature.fahrenheit.round(3)} \xC2\xB0F" 
puts "Last Humidity:    #{htu21d[:humidity].round(3)} %"
puts

# Poll temperature and humidity at different rates by calling methods on the sub-objects.
htu21d.temperature.poll(2) do |value|
  puts "Sub-Object Temperature: #{value.round(3)} \xC2\xB0C"
end
htu21d.humidity.poll(4) do |value|
  puts "Sub-Object Humidity:    #{value.round(3)} %"
end

sleep
