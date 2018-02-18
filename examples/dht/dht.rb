#
# Example of how to use the DHT class for DHT 11 and DHT 22 sensors.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new(device: "/dev/cu.usbmodem1431"))
dht = Dino::Components::DHT.new(pin: 7, board: board)

# The DHT class pre-processes raw data from the board. When it reaches callbacks
# it's already hash of :temperature and :humidity keys, both with Float values.
dht.add_callback do |reading|
  print "#{Time.now.strftime '%Y-%m-%d %H:%M:%S'} - "
  if reading[:error]
    puts "Error: #{reading[:error]}"
  else
    print "#{reading[:celsius]} \xC2\xB0C | #{reading[:farenheit]} \xC2\xB0F | "
    puts "#{reading[:humidity]}% relative humidity"
  end
end

# Read it every 5 seconds.
dht.poll(5)
sleep
