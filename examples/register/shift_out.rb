#
# Example using the Arduino shiftOut function to write data to a shift register.
# SPI is more efficient and may work with the same hardware, so use that if possible.
#
# Multiple bytes may be written in one operation.
# Register instance stores state, and its size can be set by including :bytes when intiailizing.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)
register = Dino::Components::Register::ShiftOut.new  board: board,
                                                     pins:  {latch: 9, data: 11, clock: 13}
                                                     # bit_order: :msbfirst
                                                     # bytes: 1
                                                     # buffer_writes: true
                                 
# Write a single byte
register.write(255)

# Write an array of bytes (for multiple registers).
register.write([255, 0])

# Register can behave as a BoardProxy, with components addressable directly.
led = Dino::Components::Led.new(board: register, pin: 0)
led.blink 1

sleep
