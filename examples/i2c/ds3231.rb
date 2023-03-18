#
# Small example to show how I2C works. Sets  time on a DS3231
# real-time-clock, and reads it back every 5 seconds.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)

# Only pass the SDA pin of the I2C bus. SCL (clock) pin must be 
# connected for it to work, but we don't need to control it.
#
# Arduino Uno:        SDA = 'A4'   SCL = 'A5'
# Leonardo:           SDA =   2    SCL =   3
# Due / Mega / Zero:  SDA =  20    SCL =  21
# ESP8266 :           SDA =   4    SCL =   5
# ESP32:              SDA =  21    SCL =  22
#
# On the ESP8266, 'D2' and 'D1' also map to SDA and SCL respectively.
# This is for convenience when working with common development boards.
#
bus = Dino::Components::I2C::Bus.new(board: board, pin: 'A4')

# The bus auto searches for devices on intiailization.
puts "No I2C devices connected!" if bus.found_devices.empty?
bus.found_devices.each do |address|
  puts "I2C device connected with address: 0x#{address.to_s(16)}"
end

# 0x68 or 140 is the I2C address for most real time clocks.
unless (bus.found_devices.include? 0x68)
  puts "No real time clock found!" unless bus.found_devices.empty?
else
  puts; puts "Using real time clock at address 0x68"; puts
  rtc = Dino::Components::I2C::DS3231.new(bus: bus, address: 0x68)
  rtc.time = Time.now

  5.times do
    puts rtc.time
    sleep 5
  end
end
