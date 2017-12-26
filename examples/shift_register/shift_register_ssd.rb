#
# This examples sets up a shift register, and an SSD that is connected to its 8 output pins.
# The shift register is passed in as the 'board' when setting up the SSD.
# The individual pins on the register are accessible by the SSD instance, so it works as usual.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)
shift_register = Dino::Components::ShiftRegisterOut.new(pins: {data: 11, latch: 8, clock: 12}, board: board)

ssd   = Dino::Components::SSD.new(
  board: shift_register,
  pins:  { cathode: 0, a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7 }
)

# Turn off the ssd on exit
trap("SIGINT") { exit !ssd.off }

# Display each new line on the ssd
loop { ssd.display(gets.chomp) }
