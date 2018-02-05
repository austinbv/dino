#
# Example of how to use the Dallas DS18B20 temperature sensor.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)
bus = Dino::Components::OneWire::Bus.new(pin:16, board: board)

# The bus does parasite power detection on startup.
# It can tell that parasite power is in use, but not by WHICH devices.
if bus.parasite_power
  puts "Parasite power detected..."; puts
end

# The bus automatically searches when initialized. It finds the address of
# every device, identifies the device type and matching Ruby class, storing here.
puts "Found #{bus.found_devices.count} devices on the bus:"
puts bus.found_devices.inspect; puts

# We can use the search results to setup instances of the device classes.
ds18b20s = []
bus.found_devices.each do |d|
  if d[:class] == Dino::Components::OneWire::DS18B20
    ds18b20s << Dino::Components::OneWire::DS18B20.new(board: bus, address: d[:address])
  end
end

#  Format a reading for printing on a line.
def print_reading(reading, sensor, i)
  print "#{Time.now.strftime '%Y-%m-%d %H:%M:%S'} - "
  print "index: #{i}, serial# :#{sensor.serial} "

  if reading[:crc_error]
    puts "CRC check failed for this reading!"
  else
    print "#{reading[:celsius]} \xC2\xB0C / #{reading[:farenheit]} \xC2\xB0F / "
    puts "Raw: #{reading[:raw].inspect}"
  end
end

# Read the temp from each sensor in a simple loop.
loop do
  ds18b20s.each_with_index { |s,i| print_reading(s.read, s, i) }
  sleep 5
end
