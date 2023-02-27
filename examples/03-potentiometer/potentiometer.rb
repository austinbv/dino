#
# Example 3: Potentiometer and Analog Inputs
#
require 'bundler/setup'
require 'dino'

# Set up the board, connecting with serial over USB
board = Dino::Board.new(Dino::TxRx::Serial.new)

#
# Connect the potentiometer's outer 2 pins to Ground and Vcc respectively.
# The center is the wiper, and should be connected to one of the board's analog
# pins. On most boards these pins start with 'A' and can be given as strings.
#
# See potentiometer.pdf in this folder for a hook-up diagram.
# 
potentiometer = Dino::Components::Potentiometer.new(pin: 'A0', board: board)

#
# Like with Button, the Board starts reading the Potentiometer value immediately,
# but we need to add a callback to do something with it.
#
potentiometer.on_change do |value|
  print "Potentiometer value: #{value} \r"
end
puts "Turn the potentiometer to change value. Press Enter to continue..."

# Stop the callback.
gets; puts
potentiometer.remove_callbacks

#
# The default resolution for Analog Input is 10-bits, so you should have seen
# values from 0 - 1023. We can use the value to control the blinking
# speed of the LED from the earlier example.
# 
led = Dino::Components::Led.new(board: board, pin: 13)

# Helper method to calculate the blink time.
def map_pot_value(value)
  # Map 10 bit value into 0 to 1 range.
  fraction = value / 1023.to_f

  # Linearization hack for audio taper potentiometers.
  # Adjust k for different tapers. This was an A500K.
  k = 5
  linearized = (fraction * (k + 1)) / ((k * fraction) + 1)
  # Use this for linear potentiometers instead.
  # linearized = fraction 
  
  # Map to the 0.1 to 0.5 seconds range in reverse. Clockwise = faster.
  0.5 - (linearized * 0.4)
end

# Callback that calculates the blink interval and tells the LED.
potentiometer.on_change do |value|
  interval = map_pot_value(value)
  print "LED blink interval: #{interval.round(4)} seconds    \r"
  led.blink(interval)
end
puts "Turn potentiometer to control the LED blink. Press Ctrl+C to exit..."
sleep
