#
# Example of an output SPI shift register driving a seven segment display.
#
# The register is a BoardProxy, and implements enough Board methods that
# DigitalOutput components can use its pins directly.
#
# The SSD object is created by using the register in place of board, and
# the register output pins that the SSD is connected to.
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

board = Dino::Board.new(Dino::Board::Connection::Serial.new)

spi = Dino::SPI::Bus.new(board: board)

shift_register = Dino::Register::SPIOutput.new  bus: spi,
                                                pin: 9
                                                # frequency: 3000000,
                                                # spi_mode: 0,
                                                # bytes: 1
                                                # bit_order: :msbfirst
                                                # buffer_writes: true

ssd = Dino::LED::SevenSegment.new board: shift_register,
                                  pins:  { cathode: 0, a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7 }

# Turn off the ssd on exit
trap("SIGINT") { exit !ssd.off }

# Display each new line on the ssd
loop { ssd.display(gets.chomp) }
