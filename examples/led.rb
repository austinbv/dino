#
# This is a simple example to blink an led
# every half a second
#

require '../lib/dino'

board = Dino::Board.new(Dino::TxRx.new)
led = Dino::Led.new(pin: 13, board: board)

[:on, :off].cycle do |switch|
  led.send(switch)
  sleep 0.5
end