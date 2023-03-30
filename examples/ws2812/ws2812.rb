#
# Example of writing to a WS2812(B) / NeoPixel LED strip.
#
require 'bundler/setup'
require 'dino'

RED = [255, 0, 0]
GREEN = [0, 255, 0]
BLUE = [0, 0, 255]
WHITE = [255, 255, 255]
OFF = [0, 0, 0]
PIXELS = 8
position_array = (0..PIXELS-1).to_a.concat (1..PIXELS-2).to_a.reverse

board = Dino::Board.new(Dino::Board::Connection::Serial.new)
strip = Dino::LED::WS2812.new(board: board, pin: 4, length: PIXELS)

# Bounce a red pixel back and forth on the strip.
loop do
  position_array.each do |index|
    strip.clear
    strip[index] = RED
    strip.show
    sleep 0.05
  end

  position_array.each do |index|
    strip.clear
    strip[index] = GREEN
    strip.show
    sleep 0.05
  end

  position_array.each do |index|
    strip.clear
    strip[index] = BLUE
    strip.show
    sleep 0.05
  end

  position_array.each do |index|
    strip.clear
    strip[index] = WHITE
    strip.show
    sleep 0.05
  end
end
