#
# This example writes "Hello World!" in the display
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::Connection::Serial.new)
lcd = Dino::Display::HD44780.new  board: board,
                                  pins: { rs: 8, enable: 9, d4: 4, d5: 5, d6: 6, d7: 7 },
                                  cols: 16,
                                  rows: 2

# Bitmap for a custom character. 5 bits wide x 8 high.
# Useful for generating these: https://omerk.github.io/lcdchargen/
heart = [	0b00000,
        	0b00000,
        	0b01010,
        	0b11111,
        	0b11111,
        	0b01110,
        	0b00100,
        	0b00000 ]
                  
# Define the character in CGRAM address 2. 0-7 are usable.
lcd.create_char(2, heart)

# Need to call home/clear/set_cursor so we go back to writing DDRAM.
lcd.home

# End the first line with the heart by writing its CGRAM address.
lcd.print "Hello World!   "
lcd.write(2)

# Display a clock on second line, updating approximately every second.
loop do
  lcd.move_to 0,1
  lcd.print(Time.now.strftime("%I:%M:%S"))
  sleep 1
end
