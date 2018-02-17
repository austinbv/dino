#
# Somewhat pointless example to ensure I2C is working. Sets the time on a
# connected DS3231 real-time-clock and reads it back every 5 seconds.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)

# Only pass in the SDA pin of the I2C bus. SCL (clock) pin MUST be properly
# connected for things to work, but we don't need to control it.
#
# Most Arduinos: SDA = 'A4'   SCL = 'A5'
# Leonardo:      SDA =   2    SCL =   3
# Due and Mega:  SDA =  20    SCL =  21
# ESP8266 :      SDA =   4    SCL =   5
#
# On the ESP8266, 'D2' and 'D1' also map to SDA and SCL respectively.
# This is for convenience when working with common development boards.
#
bus = Dino::Components::I2C::Bus.new(board: board, pin: 4)
rtc = Dino::Components::I2C::DS3231.new(bus: bus, address: 104)

rtc.time = Time.now

loop do
  puts rtc.time
  sleep 5
end
