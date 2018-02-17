#
# Somewhat pointless example to ensure I2C is working. Sets the time on a
# connected DS3231 real-time-clock and reads it back every 5 seconds.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)

# For now you need to pass in the SDA pin of the I2C interface Arduino/Wire uses.
# Most Arduinos: A4
# Leonardo: 2
# Due and Mega: 20
# ESP8266 : 4 (D2 on WeMos/NodeMCU = GPIO 4 on the ESP8266 itself)
bus = Dino::Components::I2C::Bus.new(board: board, pin: 4)
rtc = Dino::Components::I2C::DS3231.new(bus: bus, address: 104)

rtc.time = Time.now

loop do
  puts rtc.time
  sleep 5
end
