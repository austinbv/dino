#
# Example using an ADS1118 ADC over the SPI bus.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::Connection::Serial.new)

# Connect the ADS1118 pins to the board's default SPI pins.
bus = Dino::SPI::Bus.new(board: board)

# Or use a 2-way bit-bang SPI bus on any pins.
# SPI_BIT_BANG_PINS   = { clock: 13, input: 12, output: 11 }
# bus = Dino::SPI::BitBang.new(board: board, pins: SPI_BIT_BANG_PINS)

# Connect chip select/enable pin of the ADS1118 to pin 9.
ads1118 = Dino::AnalogIO::ADS1118.new(bus: bus, pin: 9)

# Helper method so readings look nice.
def print_reading(name, raw, voltage)
  print "#{Time.now.strftime '%Y-%m-%d %H:%M:%S'} - "
  print "#{name.rjust(12, " ")} | "
  print "Raw: #{raw.to_s.rjust(6, " ")} | "
  print "Voltage: "
  print ("%.10f" % voltage).rjust(13, " ")
  puts " V"
end

#
# Read the ADS1118 internal temperature sensor.
# This always uses the 128 SPS mode, and there is no polling method for it.
# 
temperature = ads1118.temperature_read
puts "ADS1118 Temperature: #{temperature} \xC2\xB0C"
puts

#
# Use the ADS1118 directly by writing values to its config registers.
# ADS1118#read automatically waits for conversion time and gets the 16-bit reading.
# See datasheet for register bitmaps.
#
# Note: This is the only way to use continuous mode. Subcomponents always use one-shot.
#
ads1118.read([0b10000001, 0b10001011]) do |reading|
  voltage = reading * 0.0001875
  print_reading("Direct", reading, voltage)
end

#
# Or use its BoardProxy interface, adding subcomponents as if it were a Board.
# The key adc: can substitute for board: when intializing AnalogIO::Input.
#
# Gain and sample rate bitmasks can be found in the datasheet.
#
# Input on pin 0, with pin 1 as differential negative input, and 6.144 V full range.
diff_input = Dino::AnalogIO::Input.new(adc: ads1118, pin: 0, negative_pin: 1, gain: 0b000)

# Input on pin 2 with no negative input (single ended), and 1.024V full range.
# Ths one uses a 8 SPS rate, essentially 16x oversampling compared to the default 128.
single_input = Dino::AnalogIO::Input.new(adc: ads1118, pin: 2, gain: 0b011, sample_rate: 0b000)

# Poll the differential input every second.
diff_input.poll(1) do |reading|
  voltage = reading * diff_input.volts_per_bit
  print_reading("Differential", reading, voltage)
end

# Poll the single ended input every 2 seconds.
single_input.poll(2) do |reading|
  voltage = reading * single_input.volts_per_bit
  print_reading("Single", reading, voltage)
end

sleep
