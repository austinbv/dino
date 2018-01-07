#
# Example of how to use the DHT class for DHT 11 and DHT 22 sensors.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)
dht = Dino::Components::DHT.new(pin: 7, board: board)

# The DHT class pre-processes raw data from the board. When it reaches callbacks
# it's already hash of :temperature and :humidity keys, both with Float values.
dht.add_callback do |data|
  puts "The temperature is #{data[:temperature]} degrees Celsius"
  puts "The relative humidity is #{data[:humidity]}%"
end

# Read it every 10 seconds.
dht.poll(10)
sleep
