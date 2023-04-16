#
# Example showing 2 SPI devices on the same bus with different select pins.
# Combination of examples/spi_input.rb and examples/spi_output.rb
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::Board::Connection::Serial.new)

# Create a 2-way bit bang SPI interface on any pins (slower, but flexible).
bus = Dino::SPI::BitBang.new(board: board, pins: { clock: 52, input: 50, output: 51 })

# Or use the default hardware SPI interface on its predefined pins (fast).
# bus = Dino::SPI::Bus.new(board: board)

# Output register needs a bus and a pin (its latch / select pin).
out_register = Dino::SPI::OutputRegister.new  bus: bus,
                                              pin: 10
                                              # bit_order: :msbfirst
                                              # frequency: 1000000
                                              # spi_mode: 0
                                              # bytes: 1
                                              # buffer_writes: true

# Input register needs a bus and a pin (its latch / select pin).
# The CD4021 register works most reliably in SPI mode 2.
in_register = Dino::SPI::InputRegister.new  bus: bus,
                                            pin: 9,
                                            spi_mode: 2
                                            # bit_order: :msbfirst
                                            # frequency: 1000000
                                            # bytes: 1

# LED connected to the output register.
led = Dino::LED.new(board: out_register, pin: 0)                                 

# Button connected to the input register.
button = Dino::DigitalIO::Button.new(board: in_register, pin: 0)

button.down do
  puts "Button pressed:  LED on"
  led.on
end

button.up do
  puts "Button released: LED off"
  led.off
end

# Force callbacks to run at least once for the initial state.
led.off
button.read

sleep
