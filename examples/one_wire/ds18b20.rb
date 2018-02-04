#
# Example of how to use the Dallas DS18B20 temperature sensor.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)
bus = Dino::Components::OneWire::Bus.new(pin:16, board: board)
ds18b20 = Dino::Components::OneWire::DS18B20.new(board: bus)

# Bus can detect if a device is using parasite power, but not WHICH devices.
if bus.parasite_power
  puts "Parasite power detected..."; puts
end

# Blocking read that returns the read value.
temp = ds18b20.read[:celsius]
puts "Single read: #{temp} \xC2\xB0C"

# Read the most recent value from the component's @state variable.
sleep 0.5
temp = ds18b20.state[:celsius]
puts "Read from last state: #{temp} \xC2\xB0C"

# Poll the sensor every 5 seconds with a callback showing C, F and raw bytes.
puts
puts "Start polling..."
ds18b20.poll(5) do |reading|
  print "#{Time.now.strftime '%Y-%m-%d %H:%M:%S'} - "

  if reading[:crc_error]
    puts "CRC check failed for this reading!"
  else
    print "#{reading[:celsius]} \xC2\xB0C / #{reading[:farenheit]} \xC2\xB0F / "
    puts "Raw: #{reading[:raw].inspect}"
  end
end

sleep
