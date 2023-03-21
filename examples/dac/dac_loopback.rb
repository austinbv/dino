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

board = Dino::Board.new(Dino::TxRx::Serial.new)
dac = Dino::Components::Basic::DACOut.new(pin: DAC_PIN, board: board)
adc = Dino::Components::Basic::AnalogInput.new(pin: ADC_PIN, board: board)

#
# DACOut resolution is 8 bits default on most chips.
# AnalogIn resolution can be any of 10, 8 or 12-bits by default, depending on chip.
# Read values should be close to 1x, 4x, or 16x the written values respectively.
#
[0, 32, 64, 128, 192, 255].each do |output_value|
  dac.write output_value
  sleep 1
  loopback_value = adc.read
  puts "ADC reads: #{loopback_value} when DAC writes: #{output_value}"
end

board.finish_write
