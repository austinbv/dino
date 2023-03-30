#
# This is an example of how to use the sensor class
# You must register data callbacks and have the main thread
# sleep or in someway keep running or your program
# will exit before any callbacks can be called
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::Board::Connection::Serial.new)
sensor = Dino::AnalogIO::Sensor.new(pin: 'A0', board: board)

# Single read with block as callback. Blocks main thread.
# Callback fires only once then is removed automatically.
sensor.read { |value| puts "#{Time.now} Single read: #{value}" }

# Poll the sensor every 1 second with block as callback. Does not block main thread.
# Callback fires every time data is received until #stop is called.
sensor.poll(1) { |value| puts "#{Time.now} Polling: #{value}" }
sleep 5

# Stop polling. Automatically removes the callback from the #poll block.
sensor.stop

# Continuous listen with block as callback. Fires every time data is received until #stop is called.
sensor.listen { |value| puts "#{Time.now} Listening: #{value}" }
sleep 0.5

# Stop listening. Automatically removes the callback from the #listen block.
sensor.stop

# Add a persistent callback.
sensor.on_data { |value| puts "#{Time.now} Persistent callback: #{value}" }

# Add a callback with a custom key.
sensor.on_data(:test) { |value| puts "#{Time.now} Keyed callback: #{value}"}

# Single read again. Block given fires only once. Callbacks added with #on_data fire also.
sensor.read { |value| puts "#{Time.now} Single read again: #{value}" }

# Continuous listen. Block fires each time. Callbacks added with #on_data continue to fire.
sensor.listen { |value| puts "#{Time.now } Listening again: #{value}" }
sleep 0.5

# Stop listening. Automatically removes the callback from the #listen block.
sensor.stop

# Remove callbacks keyed with :test.
sensor.remove_callbacks(:test)

# Remove all callbacks.
sensor.remove_callbacks
