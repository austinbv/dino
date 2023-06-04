#
# Example that writes to bit bang UART and reads back on hardware UART1. Tested on Arduino Mega.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::Connection::Serial.new)

hw_uart = Dino::UART::Hardware.new(board: board, index: 1, baud: 31250)
bb_uart = Dino::UART::BitBang.new(board: board, pins: { rx:10, tx:11 }, baud: 31250)

bb_uart.write("Hello World!\n")

sleep 1

puts hw_uart.gets
