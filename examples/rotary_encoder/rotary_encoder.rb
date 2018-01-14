#
# Example of a smiple rotary encoder polling at ~1ms.
# Not as precise as using an interrupt and hardware debounce, but should be OK
# at lower speeds. 1ms polling is kind of a free software debounce anyway?
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)
encoder = Dino::Components::RotaryEncoder.new board: board,
                                              pins:{ data: 4, clock: 5 }

encoder.add_callback do |data|
  puts "Encoder position: #{data}"
end

sleep
