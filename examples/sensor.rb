#
# This is an example of how to use the sensor class
# You must register data callbacks and have the main thread
# sleep or in someway keep running or your program
# will exit before any callbacks can be called
#
require '../lib/dino'

board = Dino::Board.new(Dino::TxRx.new)
sensor = Dino::Sensor.new(pin: 'A0', board: board)

current_state = nil

on_data = Proc.new do |data|
    puts data
end

sensor.when_data_received(on_data)

sleep