#
# This is an example of how to use the HCSR04 ultrasonic distance sensor.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)
sensor = Dino::Components::HCSR04.new(pin: 52, board: board)

# Read the distance every 5 seconds.
sensor.poll(5) do |reading|
  # Convert microseconds to inches
  inches = (reading.to_f / (2 * 73.746)) 
  puts "#{inches} in."
end

sleep
