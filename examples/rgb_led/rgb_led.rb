#
# This is a simple example to blink an led
# every half a second
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)
led = Dino::Components::RGBLed.new(pins: {red: 11, green: 10, blue: 9}, board: board)
potentiometer = Dino::Components::Sensor.new(pin: 'A0', board: board)


delay = 500.0

potentiometer.on_data do |data|
  sleep 0.5
  puts "DATA: #{delay = data.to_i}"
end

  sleep(2)
loop do
  puts "DELAY: #{seconds = (delay / 1000.0)}"
  p 'red'
  led.color = :red
  sleep(seconds)
  p 'blue'
  led.color = :blue
  sleep(seconds)
  p 'green'
  led.color = :green
  sleep(seconds)
end
#led.color(224, 27, 106)
#sleep(1)
#led.color(255, 149, 7)
#sleep(1)
#led.off
