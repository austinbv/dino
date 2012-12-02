#
# This is an example of how to use the servo class
#

require File.expand_path('../../lib/dino', __FILE__)

board = Dino::Board.new(Dino::TxRx.new)
servo = Dino::Components::Servo.new(pin: 9, board: board)

loop do
  servo.position += 9
  sleep 0.5
end
