#
# Example showing 2 SPI devices on the same bus with different select pins.
# Combination of examples/spi_ssd.rb and examples/spi_in.rb
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)
output_register = Dino::Components::Register::SPIOut.new board: board,
                                                         pin: 9
                                                         # frequency: 3000000,
                                                         # spi_mode: 0,
                                                         # bytes: 1
                                                         # bit_order: :lsbfirst

ssd = Dino::Components::SSD.new   board: output_register,
                                  pins:  { cathode: 0, a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7 }

input_register = Dino::Components::Register::SPIIn.new  board: board,
                                                        pin: 8,
                                                        spi_mode: 0,
                                                        frequency: 3000000
                                                        # bytes: 1
                                                        # bit_order: :lsbfirst

button = Dino::Components::Button.new(pin: 0, board: input_register)

button.down { puts "down"}
button.up   { puts "up"  }

# Force callbacks to run at least once for the initial state.
button.read

# Turn off the ssd on exit
trap("SIGINT") { exit !ssd.off }

# Display each new line on the ssd
loop { ssd.display(gets.chomp) }
