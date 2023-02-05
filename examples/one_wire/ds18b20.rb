#
# Example of how to use the Dallas DS18B20 temperature sensor.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)
bus = Dino::Components::OneWire::Bus.new(pin:16, board: board)

# The bus detects parasite power automatically when initialized.
# It can tell that parasite power is in use, but not by WHICH devices.
if bus.parasite_power
  puts "Parasite power detected..."; puts
end

# Call #device_present to reset the bus and return presence pulse as a boolean.
if bus.device_present?
  puts "Devices present on bus..."; puts
else
  puts "No devices present on bus... Quitting..."
  return
end

# Calling #search finds connected devices and stores them in #found_devices.
# Each hash contains a device's ROM address and matching Ruby class if one exists.
bus.search
count = bus.found_devices.count
puts "Found #{count} device#{'s' if count > 1} on the bus:"
puts bus.found_devices.inspect; puts

# We can use the search results to setup instances of the device classes.
ds18b20s = []
bus.found_devices.each do |d|
  if d[:class] == Dino::Components::OneWire::DS18B20
    ds18b20s << d[:class].new(bus: bus, address: d[:address])
  end
end

#  Format a reading for printing on a line.
def print_reading(reading, sensor)
  print "#{Time.now.strftime '%Y-%m-%d %H:%M:%S'} - "
  print "Serial(HEX): #{sensor.serial_number} | Res: #{sensor.resolution} bits | "

  if reading[:crc_error]
    puts "CRC check failed for this reading!"
  else
    print "#{reading[:celsius]} \xC2\xB0C | #{reading[:farenheit]} \xC2\xB0F | "
    puts "Raw: #{reading[:raw].inspect}"
  end
end

ds18b20s.each do |sensor|
  sensor.poll(5) do |reading|
    print_reading(reading, sensor)
  end
end

sleep
