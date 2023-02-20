#
# Example of writing to software serial.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new(device: "/dev/cu.usbmodem14B01"))

# Even though an Rx pin is given here (it's needed by the lbirary), only transmission works for now.
soft_serial = Dino::Components::SoftwareSerial.new board: board, pins: { rx:10, tx:11 }, baud: 9600

soft_serial.puts "Hello World!"

# The board writes asynchronously. Make sure it has written everything before we exit.
board.finish_write
