#
# Example showing 2 SPI devices on the same bus with different select pins.
# Combination of examples/spi_ssd.rb and examples/spi_in.rb
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::Board::Connection::Serial.new)
output_register = Dino::Register::SPIOutput.new board: board,
                                                pin: 9
                                                # frequency: 1000000
                                                # spi_mode: 0
                                                # bit_order: :msbfirst
                                                # bytes: 1
                                                # buffer_writes: true

ssd = Dino::LED::SevenSegment.new board: output_register,
                                  pins:  { cathode: 0, a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7 }

input_register = Dino::Register::SPIInput.new board: board,
                                              pin: 8
                                              # frequency: 1000000
                                              # spi_mode: 0
                                              # bit_order: :msbfirst
                                              # bytes: 1
                                                        
button = Dino::DigitalIO::Button.new(pin: 0, board: input_register)

button.down { puts "down"}
button.up   { puts "up"  }

# Force callbacks to run at least once for the initial state.
button.read

# Turn off the ssd on exit
trap("SIGINT") { exit !ssd.off }

# Display each new line on the ssd
loop { ssd.display(gets.chomp) }
