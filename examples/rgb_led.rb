#
# This is a simple example to blink an led
# every half a second
#

require '../lib/dino'

board = Dino::Board.new(Dino::TxRx.new)
led = Dino::RgbLed.new(red_pin: 9, green_pin: 10, blue_pin: 11, board: board)

sleep 0.01
led.red
sleep(1)
led.blue

sleep