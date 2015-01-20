#
# This is an example of how to use the button class
# You must register helpers and have the main thread
# sleep or in someway keep running or your program
# will exit before any callbacks can be called
#
require 'bundler/setup'
require 'smalrubot'

board = Smalrubot::Board.new(Smalrubot::TxRx::Serial.new)
button = Smalrubot::Components::Button.new(pin: 13, board: board)

button.down do
  puts "button down"
end

button.up do
  puts "button up"
end

sleep
