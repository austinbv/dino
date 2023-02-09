#
# This is a simple example to blink an led
# every half a second
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)

# Initialization automatically gets all EEPROM data from the board.
# eeprom = Dino::Components::Basic::BoardEEPROM.new(board: board)
eeprom = board.eeprom

# EEPROM size reported by the board.
puts "EEPROM Size: #{eeprom.length} bytes"

# Write values like an array.
eeprom[0] = 128
eeprom[1] = 127

# Changes do not save to the board automatically.
# Call #save to write to the board, and automatically reload from it.
eeprom.save

# Read values like an array.
puts "Address 0 contains: #{eeprom[0]}"

# Enumerate like an array.
eeprom.each_with_index do |byte, address|
  if address == 1
    puts "Address #{address} contains #{byte}"
  end
end


