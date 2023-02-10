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
                                              divider: 1,            # (default) read approx every divider ms
                                              degrees_per_step: 12   # (default) angular degrees the encoder moves between steps

encoder.add_callback do |data|
  puts "Encoder position: #{data[:position]}°"
  puts "Encoder change: #{data[:change]}"
end

sleep
