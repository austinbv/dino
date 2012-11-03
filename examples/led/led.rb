#
# This is a simple example to blink an led
# every half a second
#

require File.expand_path('../../../lib/dino', __FILE__)

board = Dino::Board.new(Dino::TxRx.new)
led = Dino::Components::Led.new(pin: 13, board: board)

[:on, :off].cycle do |switch|
  led.send(switch)
  sleep 0.5
end
