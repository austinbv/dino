#
# Example of a smiple rotary encoder polling at ~1ms.
#
# WARNING: This method is not precise at all. Please do not use it for anything
# that requires all steps to be read for precise positioning or high speed.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)
encoder = Dino::Components::RotaryEncoder.new board: board,
                                              pins:{ clock: 4, data: 5 },
                                              divider: 1, # (default) read approx every divider ms
                                              steps: 30   # (default) steps / revolution

encoder.add_callback do |data|
  puts "Encoder position: #{data[:position]}°"
  puts "Encoder change: #{data[:change]}"
end

sleep
