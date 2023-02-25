#
# Example of input components connected to an input SPI shift register.
#
# The register is a BoardProxy, and implements enough Board methods that
# DigitalInput components can be attached to its pins. 
#
# The Button object is created by using the register in place of board, and
# the register output pin that it's connected to.
#
# The board pin connected to the register's select/latch pin is required to initialize.
# Each device connected to the SPI bus needs a unique select pin on the board.
#
# Clock and data pins do not need to be specified when using SPI, since they are
# predetermined on the board and shared by all SPI devices, but they must be connected.
# Pin mapping varies depending on the board.
# A reference can be found here: https://www.arduino.cc/en/Reference/SPI
#
# SPI output (MISO) and SPI clock (SCLK) map to pins 12 and 13 respectively on the Arduino UNO.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)

# Tested with CD4021B register, which is LSBFIRST, but needs SPI mode 0 on some boards and 2 on others.
shift_register = Dino::Components::Register::SPIIn.new  board: board,
                                                        pin: 8,
                                                        spi_mode: 2,
                                                        # bit_order: :lsbfirst
                                                        # frequency: 1000000
                                                        # bytes: 1

button = Dino::Components::Button.new(pin: 0, board: shift_register)

button.down { puts "down"}
button.up   { puts "up"  }

# Force callbacks to run at least once for the initial state.
button.read

sleep
