#
# Example 5: RGB LED
#
require 'bundler/setup'
require 'dino'

# Set up the board, connecting with serial over USB
board = Dino::Board.new(Dino::Board::Connection::Serial.new)

#
# To set up an RGB LED, connect its cathode leg to ground, and each of its 3 color
# anodes to PWM-capable pin on your board, through a current limiting resistor. Make
# the green resistor much larger. Since green is usually brighter, we want to limit
# its current more than the others. See rgb_led.pdf for a hook-up diagram.
# The values used are 4.7k Ohm for green, 220 Ohm for red and blue.
#
# An RGB LED is really 3 individual LEDS in one, sharing a cathode (sometimes anode).
# We could initailize them separately, or use the RGBLed class, which takes all 3 pins.
#
rgb_led = Dino::LED::RGB.new(pins: {red: 11, green: 10, blue: 9}, board: board)

#
# We can call methods on the RGBLed as a whole. For example, these 8 defined colors.
#
print "Press Enter to cycle through RGBLed defined colors..."; gets
[:red, :green, :blue, :cyan, :yellow, :magenta, :white, :off].each do |color|
  rgb_led.color = color
  sleep 0.5
end

#
# Or we can access the individual Leds through the #red, #green and #blue methods.
# This makes an orange color with them.
#
rgb_led.red.write 255
rgb_led.green.write 100
rgb_led.blue.off
print "Done. Changed to orange. Press Enter to continue..."; gets

# Let's bring the potentiometer back from the previous examples.
potentiometer = Dino::AnalogIO::Potentiometer.new(pin: 'A0', board: board)

#
# In a separate file (rgb_mapping.rb), there are methods to map the 0-1023 values
# received from the potentiometer into RGB values that create a rough color spectrum.
#
require_relative 'rgb_mapping'
potentiometer.on_change do |pot_value|
  # Use the mapping methods to calculate values and write them.
  rgb_led.red.write   map_red(pot_value)
  rgb_led.green.write map_green(pot_value)
  rgb_led.blue.write  map_blue(pot_value)
  
  print "Potentiometer value: #{pot_value}   \r"
end

puts "Turn potentiometer to change the RGB LED color. Press Ctrl+C to exit..."
sleep
