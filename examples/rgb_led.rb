#
# This is a simple example to blink an led
# every half a second
#

require '../lib/dino'

board = Dino::Board.new(Dino::TxRx.new)
led = Dino::Component::RgbLed.new(pins: {red: 9, green: 10, blue: 11}, board: board)

sleep 0.01
led.red
sleep(1)
led.blue

sleep
