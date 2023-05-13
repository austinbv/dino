#
# Example of a Button connected through an input shift register (CD4021B).
# Can be used over either a bit bang or hardware SPI interface.
#
require 'bundler/setup'
require 'dino'

# SPI pins (on board)
SPI_BIT_BANG_PINS   = { clock: 13, input: 12 }
REGISTER_SELECT_PIN = 9

# Button pin (on register parallel outputs)
BUTTON_PIN = 0

board = Dino::Board.new(Dino::Connection::Serial.new)

# 1-way (input) bit bang SPI interface on any pins (slower, but flexible).
bus = Dino::SPI::BitBang.new(board: board, pins: SPI_BIT_BANG_PINS)

# Use the default hardware SPI bus (faster, but predetermined pins).
# bus = Dino::SPI::Bus.new(board: board)

# Show the hardware SPI pins to aid connection.
# MOSI = output | MISO = input | SCK = clock
# puts board.map.select { |name, number| [:MOSI, :MISO, :SCK].include?(name) }

# InputRegister needs a bus and its select pin. The CD4021 likes SPI mode 2.
# Other options and their defaults:
#     bytes:          1          - For daisy-chaining registers
#     spi_frequency:  1000000    - Only affects hardware SPI interfaces
#     spi_mode:       0
#     spi_bit_order:  :msbfirst
#
register = Dino::SPI::InputRegister.new(bus: bus, pin: REGISTER_SELECT_PIN, spi_mode: 2)

# InputRegister implements enough of the Board interface that digital input
# components can treat it as a Board. Do that with the Button.
#
# button starts listening automatically, which triggers register to start listening,
# so it can update button as needed. Registers listen with an 8ms interval by default,
# compared to the 4ms default for a Button directly connected to a Board.
#
button = Dino::DigitalIO::Button.new(pin: 0, board: register)

# Button callbacks.
button.down { puts "Button pressed"  }
button.up   { puts "Button released" }

# Sleep the main thread. Press the button and callbacks will run.
sleep
