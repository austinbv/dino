#
# Example that shows the default I2C bus pins, and addresses of any
# devices connected to the bus.
#
require 'bundler/setup'
require 'dino'

# Method to let the user set I2C pins.
def enter_pins
  puts  "Please manually specify I2C pins..."
  print "I2C SDA pin: "; sda = gets
  print "I2C SCL pin: "; scl = gets
  puts
  [sda.to_i, scl.to_i]
end

board = Dino::Board.new(Dino::Connection::Serial.new)

# If no board map, ask user to set pins manually.
unless board.map
  puts "Error: Pin map not available for this board"
  sda, scl = enter_pins

# Else get defaults from map.
else
  sda = board.map[:SDA] || board.map[:SDA0]
  scl = board.map[:SCL] || board.map[:SCL0]

  # If not in map, ask user to set manually.
  unless sda && scl
    puts "Error: I2C pins not found in this board's pin map"
    sda, scl = enter_pins
  end
end

puts "Using I2C interface on pins #{sda} (SDA) and #{scl} (SCL)"
puts

bus = Dino::I2C::Bus.new(board: board, pin: sda)
bus.search

if bus.found_devices.empty?
  puts "No devices found on I2C bus"
else
  puts "I2C device addresses found:"
  bus.found_devices.each do |address|
    # Print as hexadecimal.
    puts "0x#{address.to_s(16).upcase}"
  end
end

puts
board.finish_write
