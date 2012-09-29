#
# This is an example of how to use the button class
# You must register helpers and have the main thread
# sleep or in someway keep running or your program
# will exit before any callbacks can be called
#
require '../lib/dino'

board = Dino::Board.new(Dino::TxRx.new)
button = Dino::Components::Button.new(pin: 13, board: board)

button_down = Proc.new do
  puts "button down"
end

button_up = Proc.new do
  puts "button up"
end

button.down(button_down)
button.up(button_up)

sleep
