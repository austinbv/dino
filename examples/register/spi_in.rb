#
# Example showing how to read an input shift register using SPI.
#
# The register implements #digital_read and other methods expected by Components,
# and makes its parallel pins addressable (zero index), so it can proxy the Board class.
#
# The Button object is created by passing the register instead of the board, and
# the register's parallel output pin that the button is connected to.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)

#
# Pin 10 is default slave select on Arduino UNO. Connect to register "latch" input.
# Register data and clock pins go to 12 (MISO) and 13 respectively on the Arduino UNO.
#
# Clock and data pins do not need to be given when using SPI, since they are
# predetermined based on the board you are using, and dealt with by the library.
# But they still must be connected. The exact pins vary depending on the board,
# and a reference can be found here: https://www.arduino.cc/en/Reference/SPI
#
# SPI mode and frequency are specific to a TI CD4021B register. Change as needed.
#
shift_register = Dino::Components::Register::SPIIn.new  board: board,
                                                        pin: 10,
                                                        bytes: 1,
                                                        spi_mode: 3,
                                                        frequency: 3000000

button = Dino::Components::Button.new(pin: 0, board: shift_register)

button.down { puts "down"}
button.up   { puts "up"  }

# Force callbacks to run at least once for the initial state.
button.read

sleep
