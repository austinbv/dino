require 'bundler/setup'
require 'dino'
#
# This example shows how to use dino when connecting to a board via TCP.
# This applies to the WiFi and Ethernet sketches, or serial sketch + ser2net.
# Port number defaults to 3466 (dino), but may be given as a second argument.
# It must correspond to the listening port set when the board was flashed.
#
connection = Dino::TxRx::TCP.new("127.0.0.1", 3466)
# connection = Dino::TxRx::TCP.new("127.0.0.1")
# connection = Dino::TxRx::TCP.new("192.168.1.2", 3466)
#
board = Dino::Board.new(connection)
led = Dino::Components::Led.new(pin: 13, board: board)

[:on, :off].cycle do |switch|
  led.send(switch)
  sleep 0.5
end
#
# ser2net can be used to simulate a TCP interface from a board running dino serial.
# It serves the serial interface over a TCP port from the machine running ser2net.
#
# Example ser2net command for an Arduino UNO connected to a Mac:
# ser2net -u -C "3466:raw:0:/dev/cu.usbmodem621:115200"
#
# Tell dino to connect to the IP address of the Mac, at port 3466.
# Note: ser2net should be used in raw TCP mode, not telnet mode (more common).
#
# Replace /dev/cu.usbmodem621 with your dino serial device.
# Arduino UNOs should be something like /dev/ttyACM0 under Linux.
#
# http://sourceforge.net/projects/ser2net/ for more info on installing and configuring ser2net.
#
