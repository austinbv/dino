#
# Example using the SSD1306 OLED built into the LOLIN ES32-S2 PICO
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::Connection::Serial.new)

# The OLED's reset pin on this board isn't tied high. Do it manually.
reset = Dino::DigitalIO::Output.new(board: board, pin: 18)
reset.high

bus = Dino::I2C::Bus.new(board: board, pin: :SDA)
oled = Dino::Display::SSD1306.new(bus: bus, width: 128, height: 32)
canvas = oled.canvas

# Draw some text on the OLED's canvas (a Ruby memory buffer).
canvas.text_cursor = [27,31]
canvas.print("Hello World!")

# Add some shapes to the canvas.
baseline = 15
canvas.rectangle(10, baseline, 15, -15)
canvas.circle(66, baseline - 7, 8)
canvas.triangle(102, baseline, 118, baseline, 110, baseline - 15)

# Send the canvas to the OLED's graphics RAM so it shows.
oled.draw
board.finish_write
