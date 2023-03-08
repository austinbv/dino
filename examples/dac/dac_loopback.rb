#
# Example looping the Arduino Zero's DAC back into one of it's ADC pins.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)

# For the Zero, pin 'DAC0' is the same as 'A0', same as 14.
dac = Dino::Components::Basic::AnalogOutput.new(pin: 'DAC0', board: board)

# Connect A0 to A5 with a jumper.
input = Dino::Components::Basic::AnalogInput.new(pin: 'A5', board: board)

# The Arduino library does something weird with DACs if mode is set to output.
# Set it back to default input. Will separate DAC and PWM classes later.
dac.mode = :input

# Must use #analog_write and not #write because of issue above.
# write(0) and write(255) would call #digital_write.
# DAC resolution is 8 bits by default.
dac.analog_write 128

# ADC resolution is 10 bits default, so this should approximately 512.
# Try writing different values above to test.
input.poll(1) do |value|
  puts "A5 reading: #{value}"
end

sleep
