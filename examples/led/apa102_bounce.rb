#
# Walk a single pixel along the length of an APA102 strip and back,
# changing color each time it returns to position 0.
#
require 'bundler/setup'
require 'dino'

RED    = [255, 0, 0]
GREEN  = [0, 255, 0]
BLUE   = [0, 0, 255]
WHITE  = [255, 255, 255]
COLORS = [RED, GREEN, BLUE, WHITE]

# A SPI select pin of 255 is treated as no select pin.
SELECT_PIN = 255
PIXELS = 8

# Move along the strip and back, one pixel at a time.
positions = (0..PIXELS-1).to_a + (1..PIXELS-2).to_a.reverse

board = Dino::Board.new(Dino::Connection::Serial.new)

# Use the default hardware SPI bus.
bus = Dino::SPI::Bus.new(board: board)
strip = Dino::LED::APA102.new(bus: bus, pin: SELECT_PIN, length: PIXELS)

loop do
  COLORS.each do |color|
    positions.each do |index|
      strip.clear
      strip[index] = color
      strip.show
      sleep 0.05
    end
  end
end
