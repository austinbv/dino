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

# Need an unused pin since SPI interface expects a chip select pin.
APA102_PIN = 128
PIXELS = 3

# Get all the brightness values as an array.
brightness_steps = (0..31).to_a

board = Dino::Board.new(Dino::Connection::Serial.new)

# Use the default hardware SPI bus.
bus = Dino::SPI::Bus.new(board: board)
strip = Dino::LED::APA102.new(bus: bus, pin: APA102_PIN, length: PIXELS)

# Test global brightness control first.
strip[0] = RED
strip[1] = GREEN
strip[2] = BLUE

# Fade up from 0 brightness then back down.
(brightness_steps + brightness_steps.reverse).each do |value|
  strip.brightness = value
  strip.show
  sleep 0.05
end

# Test per-pixel brightness by fading different pixels different directions.
loop do
  (brightness_steps + brightness_steps.reverse).each do |value|
    strip[0] = RED   +  [value]
    strip[1] = GREEN +  [31 - value]
    strip[2] = BLUE  +  [value]
    strip.show
    sleep 0.1
  end
end
