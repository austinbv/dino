#
# Example looping the Arduino Zero's DAC back into one of its ADC pins.
#
require 'bundler/setup'
require 'dino'

#
# For the Arduino Zero: 'DAC0' = 'A0' = GPIO14.
# For the ESP32 V1:     'DAC0' = GPIO25, 'DAC1' = GPIO26, `ADC1_4` = 32
#
# Connect DAC_PIN TO ADC_PIN with a jumper to test.
#
DAC_PIN = 'DAC0'
ADC_PIN = 'A5'

board = Dino::Board.new(Dino::Board::Connection::Serial.new)
dac = Dino::AnalogIO::Output.new(pin: DAC_PIN, board: board)
adc = Dino::AnalogIO::Input.new(pin: ADC_PIN, board: board)

#
# Read values should be approximately 4x the written values, since Board#new tries to
# set output resolution at 8-bits and input to 10-bits. Not configurable on all chips.
# Scale may be off but, readings should still be proportional.
#
[0, 32, 64, 128, 192, 255].each do |output_value|
  dac.write output_value
  sleep 1
  loopback_value = adc.read
  puts "ADC reads: #{loopback_value} when DAC writes: #{output_value}"
end

board.finish_write
