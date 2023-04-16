#
# Example of a Button connected through an input shift register (CD4021B).
# Can be used over either a bit bang or hardware SPI interface.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::Board::Connection::Serial.new)

# Create a 1-way bit bang SPI interface on any pins (slower, but flexible).
bus = Dino::SPI::BitBang.new(board: board, pins: { clock: 13, input: 11 })

# Or use the default hardware SPI interface on its predefined pins (fast).
# bus = Dino::SPI::Bus.new(board: board)

# Input register needs a bus and a pin (its latch / select pin).
# The CD4021 register works most reliably in SPI mode 2.
register = Dino::SPI::InputRegister.new bus: bus,
                                        pin: 9,
                                        spi_mode: 2
                                        # frequency: 1000000
                                        # spi_mode: 0
                                        # bytes: 1

#
# The register is a BoardProxy, and implements enough Board methods that
# DigitalInputs can use its pins directly.
#
# A Button is created by using the register in place of board, and the 
# corresponding register pin connected to the Button.
#
button = Dino::DigitalIO::Button.new(pin: 0, board: register)

button.down { puts "down"}
button.up   { puts "up"  }

# Force callbacks to run at least once for the initial state.
button.read

sleep
