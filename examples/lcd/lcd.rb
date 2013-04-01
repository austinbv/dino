#
# This example writes "Hello World!" in the display
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)
lcd = Dino::Components::LCD.new(board: board, pins: "12,11,5,4,3,2")

lcd.begin(16,2)
lcd.puts("Hello World!")
sleep
