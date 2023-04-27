#
# Example of writing to software serial.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::Connection::Serial.new)

# Even though an Rx pin is given here (it's needed by the lbirary), only transmission works for now.
soft_serial = Dino::UART::Bitbang.new board: board, pins: { rx:10, tx:11 }, baud: 9600

loop do
  soft_serial.puts "Hello World!"
  puts "writing"
  sleep 1
end

# The board writes asynchronously. Make sure it has written everything before we exit.
board.finish_write
