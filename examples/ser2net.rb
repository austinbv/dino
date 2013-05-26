#
# This example shows how to use an Arduino on a remote machine via ser2net.
# Running ser2net serves up the serial connection over the network interface,
# so you can communicate with the Arduino over your local network or the Internet.
# 
# Example ser2net command for an Arduino UNO on Mac:
# ser2net -u -C "3466:raw:0:/dev/cu.usbmodem621:115200"
#
# Note that we're using ser2net in raw TCP mode and not telnet mode which is more common.
# 
# Replace /dev/cu.usbmodem621 with your Arduino device.
# Arduino UNOs are usually /dev/ttyACM0 under Linux.
#
# ser2net is preinstalled on many Linuxes. Install ser2net at the Mac Terminal with:
# brew install ser2net
#
# http://sourceforge.net/projects/ser2net/ for more info on installing and configuring ser2net.
#

require File.expand_path('../../lib/dino', __FILE__)

# The remote ser2net host is the first argument for a new TxRx::TCP.
# The second argument, port number, is optional. 3466 is default. This must match the port ser2net uses on the remote machine.
connection = Dino::TxRx::TCP.new("127.0.0.1", 3466)
board = Dino::Board.new(connection)
led = Dino::Components::Led.new(pin: 13, board: board)

[:on, :off].cycle do |switch|
  led.send(switch)
  sleep 0.5
end
