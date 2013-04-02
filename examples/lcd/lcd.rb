#
# This example writes "Hello World!" in the display
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)
lcd = Dino::Components::LCD.new(
          board: board,
          pins: { rs: 12, enable: 11, d4: 5, d5: 4, d6: 3, d7: 2 }
)

lcd.begin(16,2)
lcd.puts("Hello World!")
sleep
