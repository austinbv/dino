#
# This is a simple example to write to a shift register.
# Writing a byte of 255 sets all the output pins to high.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)
shift_register = Dino::Components::ShiftRegister.new(pins: {data: 11, latch: 8, clock: 12}, board: board)

ssd   = Dino::Components::SSD.new(
  board: shift_register,
  pins:  { cathode: 0, a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7 }
)

# Turn off the ssd on exit
trap("SIGINT") { exit !ssd.off }

# Display each new line on the ssd
loop { ssd.display(gets.chomp) }

# Write a single byte
# shift_register.write_byte(255)

# Write an array of bytes (for multiple registers).
# shift_register.write_bytes([255, 0])

# sleep
