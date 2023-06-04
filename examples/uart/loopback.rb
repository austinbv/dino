#
# Example that writes to TX pin of a hardware UART and reads back on RX pin of same UART.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::Connection::Serial.new)

uart = Dino::UART::Hardware.new(board: board, index: 1, baud: 31250)

# uart.on_data do |data|
#   puts data.inspect
# end

uart.write("Hello World!\nBye World!\n")

sleep 1

puts uart.gets
puts uart.gets
