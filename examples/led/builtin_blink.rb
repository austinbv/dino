#
# Blink example for standard built-in LEDs named :LED_BUILTIN
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::Connection::Serial.new)
led = Dino::LED.new(board: board, pin: :LED_BUILTIN)

led.blink 0.5

sleep
