#
# Example 1: Controlling an LED
#
require 'bundler/setup'
require 'dino'

# If the board is plugged into a USB port, we can talk to it with serial over USB.
io = Dino::TxRx::Serial.new

# Create an object to represent the board, giving the I/O object.
board = Dino::Board.new(io)

#
# Create an object for the LED, giving the board, and the pin that the positive
# leg of your LED is connected to. The longer leg is usually positive.
# See led.png in this folder for a hook-up diagram. 
#
# The on-board LED (marked "L") is internally connected to pin 13 on most Arduinos,
# and can be used without connecting anything.
#
led = Dino::Components::Led.new(board: board, pin: 13)

# Now we can make it blink.
puts "Blinking every half second..."

#
# A digital output can only have one of two states:
# 1 / high / on
# 0 / low / off
# We can use led.write to set it directly, or named convenience methods.
# These 3 lines all do the same thing: turn on, wait half a second, turn off.
#
led.write(1); sleep 0.5; led.write(0)
led.high;     sleep 0.5; led.low
led.on;       sleep 0.5; led.off

#
# led.toggle will set it to the opposite state each time it's called.
# Keep it blinking for 3 more seconds using #toggle.
#
6.times do
  led.toggle
  sleep 0.5
end

#
# What if we want to blink in the background?
#
# led.blink runs in a separate thread, managed by the led, and doesn't block the
# main thread. Give it the blink interval in seconds.
#
led.blink 0.5
puts "Blinking in the background... Hello from the main thread!"
sleep 3

# Calling a method that sets the state (#write, #high, #low, #on, #off)
# automatically stops the blink thread.
puts "Turning off for 2 seconds..."
led.off
sleep 2

# Blink faster indefinitely.
puts "Blinking faster forever... (Press Ctrl+C to exit)"
led.blink 0.1
sleep
