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
                                              divider: 1,                # (default) read approx every divider ms
                                              steps_per_revolution: 30   # (default)

encoder.add_callback do |state|
  puts "Encoder moved #{state[:change]} steps | CW step count: #{state[:steps]} | Current angle: #{state[:angle]}\xC2\xB0"
end

sleep
