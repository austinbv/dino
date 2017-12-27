#
# Example showing how to use an output shift register to drive a seven segment display.
#
# The register implements #digital_write and other methods expected by Components,
# and makes its parallel pins addressable (zero index), so it can proxy the Board class.
#
# The SSD object is created by passing the register instead of the board, and
# the registers's parallel pin number that each SSD pin is connected to.
#
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)
shift_register = Dino::Components::Register::ShiftOut.new  board: board,
                                                           pins: {data: 6, clock: 7, latch: 8}

ssd = Dino::Components::SSD.new   board: shift_register,
                                  pins:  { cathode: 0, a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7 }

# Turn off the ssd on exit
trap("SIGINT") { exit !ssd.off }

# Display each new line on the ssd
loop { ssd.display(gets.chomp) }
