#
# This is a simple example to blink an led
# every half a second
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)
led = Dino::Components::Led.new(pin: 13, board: board)

# Start blinking every half second.
led.blink 0.5

# Wait for 5 seconds. #blink does not block.
sleep 5

# Calling #on implicitly stops #blink.
led.on
sleep 5

# Blink faster.
led.blink 0.25
sleep
