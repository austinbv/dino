#
# This is an example of how to use the button class
# You must register helpers and have the main thread
# sleep or in someway keep running or your program
# will exit before any callbacks can be called
#
require 'bundler/setup'
require 'smalrubot'

board = Smalrubot::Board.new(Smalrubot::TxRx::Serial.new)
ir = Smalrubot::Components::IrReceiver.new(pin: 2, board: board)
led = Smalrubot::Components::Led.new(pin: 13, board: board)

n = 0

flash = Proc.new do
  n += 1
  puts "light flash #{n}"
end

sleep 2
Thread.new do
  loop do
    led.on
    sleep 0.01
    led.off
    sleep 0.01
  end
end

sleep 4
ir.flash(flash)

sleep
