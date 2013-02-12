#
# Example showing how to access an Arduino over a telnet connection.
# Running ser2net on the machine that the Arduino is connected to will serve up the serial interface over telnet.
# You can then communicate with that Arduino over your local network or the Internet.
# 
# Example ser2net command for an Arduino UNO on Mac:
# ser2net -u -C "9000:raw:0:/dev/cu.usbmodem621:115200"
# 
# Replace 9000 with the port number you want to use and /dev/cu.usbmodem621 with your Arduino device.
# Arduino UNOs are usually /dev/ACM0 under Linux.
#
# ser2net is preinstalled on many Linuxes. Install ser2net on Mac with:
# brew install ser2net
#
# http://sourceforge.net/projects/ser2net/ for more info on configuring ser2net.
#
require 'bundler/setup'
require 'dino'

# The host and port for the telnet connection must be passed in as arguments.
connection = Dino::TxRx::Telnet.new("localhost", 9000)
board = Dino::Board.new(connection)
led = Dino::Components::Led.new(pin: 13, board: board)

[:on, :off].cycle do |switch|
  led.send(switch)
  sleep 0.5
end