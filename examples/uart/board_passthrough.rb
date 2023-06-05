#
# Example using one board's UART as the transport for a second board, also running Dino.
#
# For this example, board1 (direct) is an Arduino Mega. board2 (passthrough) is an Uno,
# running Dino, with its UART pins (0, 1) connected to the Mega's UART1 pins (18, 19)
#
# This won't 100% reliable. The Rx buffer on the direct board is periodically read, so
# it can potentially overflow, causing data sent from the passthrough board to be lost.
# Eventually flow control data 
#
# Use at your own risk, but for the best possible performance:
#  1) Avoid long running commands on the direct board (eg. IR transmission, HTU21D).
#     These block the CPU enough that the Rx buffer won't be read in time to avoid overflow.
#  2) Use the lowest practical baud rate on the passthrough board. 19200 is used here, so
#     the direct board's Rx buffer takes 6x the time to fill, compared to 115200 baud.
#
require 'bundler/setup'
require 'dino'

board1 = Dino::Board.new(Dino::Connection::Serial.new)

uart = Dino::UART::Hardware.new(board: board1, index: 1)
board2 = Dino::Board.new(Dino::Connection::BoardUART.new(uart, baud: 19200))

led1 = Dino::LED.new(board: board1, pin: 13)
led1.blink(0.02)

led2 = Dino::LED.new(board: board2, pin: 13)
led2.blink(0.02)

sensor = Dino::AnalogIO::Input.new(board: board1, pin: :A0)
sensor.listen(4)

sleep
