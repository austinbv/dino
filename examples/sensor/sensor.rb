#
# This is an example of how to use the sensor class
# You must register data callbacks and have the main thread
# sleep or in someway keep running or your program
# will exit before any callbacks can be called
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)
board.analog_divider = 128
sensor = Dino::Components::Sensor.new(pin: 'A0', board: board)

# Single read with block as callback. Fires only once.
sensor.read { |value| puts "Single read value: #{value}" }; sleep 1

# Continuous listen with block as callback. Fires every time data is received until #stop_listening is called.
sensor.listen { |value| puts "Listening. Read value: #{value}" }; sleep 5

# Stop listening. Automatically removes the callback from the #listen block.
sensor.stop_listening; sleep 1

# Add a persistent callback.
sensor.on_data { |value| puts "Persistent callback: #{value}" }

# Add a keyed callback.
sensor.on_data(:test) { |value| puts "Keyed callback: #{value}"}

# Single read. All callbacks fire, block given fires only once.
sensor.read { |value| puts "#read block. Value: #{value}" }; sleep 1

# Continuous listen. All callbacks added with #on_data continue to fire, plus the block.
sensor.listen { |value| puts "#listen block. Value: #{value}" }; sleep 5

# Stop listening. Automatically removes the callback from the #listen block.
sensor.stop_listening

# Remove callbacks keyed with :test.
sensor.clear_callbacks(:test)

# Remove all callbacks.
sensor.clear_callbacks
