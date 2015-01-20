#
# This example shows how to use an Arduino with an Ethernet shield and the du_ethernet.ino sketch loaded.
# Replace the IP address in this example with the IP you used when uploading the sketch.
# The Ethernet shield uses up pin 13, so you'll need an LED on pin 5 to make sure it's working.
#
require File.expand_path('../../lib/smalrubot', __FILE__)

connection = Smalrubot::TxRx::TCP.new("192.168.0.77")
board = Smalrubot::Board.new(connection)
led = Smalrubot::Components::Led.new(pin: 5, board: board)

[:on, :off].cycle do |switch|
  led.send(switch)
  sleep 0.5
end
