#
# This example writes "Hello World!" in the display
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)
lcd = Dino::Components::HD44780.new(
          board: board,
          pins: { rs: 8, enable: 9, d4: 4, d5: 5, d6: 6, d7: 7 },
          cols: 16,
          rows: 2
)

# First line.
lcd.print "Hello World!"

# Display a clock on second line, updating approximately every second.
loop do
  lcd.set_cursor 0,1
  lcd.print(Time.now.strftime("%I:%M:%S"))
  sleep 1
end
