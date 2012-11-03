#
# This is a simple example to blink an led
# every half a second
#

require File.expand_path('../../lib/dino', __FILE__)

board = Dino::Board.new(Dino::TxRx.new)
led = Dino::Components::RgbLed.new(pins: {red: 11, green: 10, blue: 9}, board: board)
potentiometer = Dino::Components::Sensor.new(pin: 'A0', board: board)


delay = 500.0

set_delay = Proc.new do |data|
  sleep 0.5
  puts "DATA: #{delay = data.to_i}"
end

potentiometer.when_data_received(set_delay)

  sleep(2)
loop do
  puts "DELAY: #{seconds = (delay / 1000.0)}"
  p 'red'
  led.red
  sleep(seconds)
  led.blue
  p 'blue'
  sleep(seconds)
  led.green
  p 'green'
  sleep(seconds)
end
#led.color(224, 27, 106)
#sleep(1)
#led.color(255, 149, 7)
#sleep(1)
#led.off
