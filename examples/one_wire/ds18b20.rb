#
# Example of how to use the Dallas DS18B20 temperature sensor.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)
ds18b20 = Dino::Components::DS18B20.new(pin: 16, board: board)

ds18b20.poll(5) do |reading|
  # Start each reading line with a timestamp.
  print "#{Time.now.strftime '%Y-%m-%d %H:%M:%S'} - "

  if reading[:crc_error]
    puts "CRC check failed for this reading!"
  else
    # Print converted temperature in degrees C and F and raw 9 bytes from sensor.
    print "#{reading[:c]} \xC2\xB0C / #{reading[:f]} \xC2\xB0F / "
    puts "Raw: #{reading[:raw].inspect}"
  end
end

sleep
