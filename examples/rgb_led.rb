#
# This is a simple example to blink an led
# every half a second
#

require '../lib/dino'

board = Dino::Board.new(Dino::TxRx.new)
led = Dino::Component::RgbLed.new(pins: {red: 9, green: 10, blue: 11}, board: board)

sleep(2)
led.red
sleep(1)
led.blue
sleep(1)
led.green
sleep(1)
led.color(224, 27, 106)
sleep(1)
led.color(255, 149, 7)
sleep(1)
led.off