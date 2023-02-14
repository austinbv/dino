#
# Simple example that controls an LED.
#
require 'bundler/setup'
require 'dino'

# If the board is connected with a USB cable, it's most likely serial over USB.
connection = Dino::TxRx::Serial.new

# Initialize an object to represent the board, giving the connection.
board = Dino::Board.new(connection)

# Initialize an object representing the LED, giving the board and pin.
# The on-board LED (marked "L") is connectd to pin 13 on most Arduinos.
led = Dino::Components::Led.new(pin: 13, board: board)

#
# Now we can control the LED.
# Led is a DigitalOutput, so it can only have one of two states:
# 1 / high / on
# 0 / low / off
#
# We can write the state directly, or use named convenience methods.
# The 3 lines below all do the same thing: turn it on, wait half a second, turn it off.
#
led.write(1); sleep 0.5; led.write(0)
led.high;     sleep 0.5; led.low
led.on;       sleep 0.5; led.off

#
# Calling #toggle will set it to the opposite of its current state.
# Keep it blinking for 3 more seconds using #toggle.
#
6.times do
  led.toggle
  sleep 0.5
end

#
# What if we want to blink in the background?
#
# led.blink runs in a separate thread, managed by the led object,
# and doesn't block the main thread. Give it the blink interval in seconds.
#
led.blink 0.5

# Wait while it blinks for 5 seconds.
sleep 5

# Call a method that sets the state (#write, #high, #low, #on, #off) to
# automatically stop the blink thread.
led.off
sleep 2

# Blink faster indefinitely.
led.blink 0.25
sleep
