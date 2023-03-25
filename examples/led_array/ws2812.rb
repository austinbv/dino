#
# Example of writing to a WS2812(B) / NeoPixel LED strip.
#
require 'bundler/setup'
require 'dino'

RED = [255, 0, 0]
OFF = [0, 0, 0]
PIXELS = 8
position_array = (0..PIXELS-1).to_a.concat (1..PIXELS-2).to_a.reverse

board = Dino::Board.new(Dino::TxRx::Serial.new)
strip = Dino::Components::WS2812.new(board: board, pin: 4, length: PIXELS)

# Bounce a red pixel back and forth on the strip.
loop do
  position_array.cycle do |index|
    strip.clear
    strip[index] = RED
    strip.show
    sleep 0.05
  end
end
