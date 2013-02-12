#
# This is an example of how to use the servo class
#
$LOAD_PATH.unshift(File.expand_path('../../../lib', __FILE__))
require 'dino'

board = Dino::Board.new(Dino::TxRx.new)
servo = Dino::Components::Servo.new(pin: 9, board: board)

loop do
  servo.position += 9
  sleep 0.5
end
