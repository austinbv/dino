#
# Example that writes to hardware UART1 and reads back on bit bang UART. Tested on Arduino Mega.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::Connection::Serial.new)

hw_uart = Dino::UART::Hardware.new(board: board, index: 1, baud: 31250)
bb_uart = Dino::UART::BitBang.new(board: board, pins: { rx:10, tx:11 }, baud: 31250)

hw_uart.write("Hello World!\n")

sleep 1

puts bb_uart.gets
