#
# Example using one board's UART as the transport for a
# second board, also running Dino.
#
# For this example, board1 is an Arduino Mega, and board2
# is an Uno, but could be anything 5V tolerant that runs Dino.
#
require 'bundler/setup'
require 'dino'

board1 = Dino::Board.new(Dino::Connection::Serial.new)

uart = Dino::UART::Hardware.new(board: board1, index: 1, baud: 115200)

board2 = Dino::Board.new(Dino::Connection::BoardUART.new(uart))

led = Dino::LED.new(board: board2, pin: 13)

led.blink(0.5)

sleep
