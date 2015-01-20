#
# This is a simple example to blink an led
# every half a second
#
require 'bundler/setup'
require 'smalrubot'

board = Smalrubot::Board.new(Smalrubot::TxRx::Serial.new)
led = Smalrubot::Components::Led.new(pin: 13, board: board)

[:on, :off].cycle do |switch|
  led.send(switch)
  sleep 0.5
end
