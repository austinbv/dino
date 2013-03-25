#
# This example writes "Hello World!" in the display
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx.new)
lcd = Dino::Components::LCD.new(board: board)

lcd.begin(16,2)
lcd.puts("Hello World!")
sleep
