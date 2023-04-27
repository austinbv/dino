#
# Example of writing to a WS2812(B) / NeoPixel LED strip.
#
require 'bundler/setup'
require 'dino'

RED = [255, 0, 0]
GREEN = [0, 255, 0]
BLUE = [0, 0, 255]
WHITE = [255, 255, 255]
COLORS = [RED, GREEN, BLUE, WHITE]
PIXELS = 8

position_array = (0..PIXELS-1).to_a.concat (1..PIXELS-2).to_a.reverse

board = Dino::Board.new(Dino::Connection::Serial.new)
strip = Dino::LED::WS2812.new(board: board, pin: 4, length: PIXELS)

# Bounce a pixel back and forth on the strip, cycling through the colors.
loop do
  COLORS.each do |color|
    position_array.each do |index|
      strip.clear
      strip[index] = color
      strip.show
      sleep 0.05
    end
  end
end
