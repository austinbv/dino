#
# Example using a D3231 real-time-clock over I2C. Sets the time and reads it
# back every 5 seconds.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::Connection::Serial.new)

#
# Default pins for the I2C0 (first) interface on most chips:
#
# ATmega 328p:       SDA = 'A4'  SCL = 'A5' - Arduino Uno, Nano
# ATmega 32u4:       SDA =   2   SCL =   3  - Arduino Leonardo, Pro Micro
# ATmega1280 / 2560: SDA =  20   SCL =  21  - Arduino Mega
# SAM3X8E:           SDA =  20   SCL =  21  - Arduino Due
# SAMD21G18:         SDA =  20   SCL =  21  - Arduino Zero, M0, M0 Pro
# ESP8266:           SDA =   4   SCL =   5
# ESP32:             SDA =  21   SCL =  22
# RP2040:            SDA =   4   SCL =   5  - Raspberry Pi Pico (W)
#
# Only give the SDA pin of the I2C bus. SCL (clock) pin must be 
# connected for it to work, but we don't need to control it.
#
bus = Dino::I2C::Bus.new(board: board, pin: 'A4')

# Tell the bus to search for devices.
bus.search

# Show the found devices.
puts "No I2C devices connected!" if bus.found_devices.empty?
bus.found_devices.each do |address|
  puts "I2C device connected with address: 0x#{address.to_s(16)}"
end

# 0x68 or 140 is the I2C address for most real time clocks.
unless (bus.found_devices.include? 0x68)
  puts "No real time clock found!" unless bus.found_devices.empty?
else
  puts; puts "Using real time clock at address 0x68"; puts
  rtc = Dino::RTC::DS3231.new(bus: bus, address: 0x68)
  rtc.time = Time.now

  5.times do
    puts rtc.time
    sleep 5
  end
end
