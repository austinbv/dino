#
# This is an example of how to use the button class
# You must register helpers and have the main thread
# sleep or in someway keep running or your program
# will exit before any callbacks can be called
#
$: << File.expand_path('../../lib', __FILE__)
require '../lib/dino'

board = Dino::Board.new(Dino::TxRx.new)
servo = Dino::Components::Servo.new(pin: 9, board: board)

loop do
  servo.position += 9
  sleep 0.5
end
