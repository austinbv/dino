#
# This is a simple test of the IREmitter (infrared blaster) class.
# It is based on this example from the Arduino library:
# https://github.com/Arduino-IRremote/Arduino-IRremote/tree/master/examples/SendDemo
#
# To verify your emitter is working, you can flash this sketch on a second board:
# https://github.com/Arduino-IRremote/Arduino-IRremote/tree/master/examples/ReceiveDemo
#
# Attach an IR receiver to the receive pin (2 for Atmel AVR) and observe for serial output.
#
# If you don't have 2 boards, use the receive sketch to capture a code from a button
# of a remote you have. Copy the raw code (long list of numbers in curly braces),
# and modify it into a Ruby array. 
#
# Reflash the dino sketch onto your board and test the IR code operates your device.
#
# Both of these methods require you to have an IR receiver handy.
# If you do not have one, there are IR codes in Raw format for many devices
# available on sites like http://irdb.tk/codes/
# When formatted as a string of numbers with + and - in front of each number,
# you will need to convert them to the array format before use.
#
require 'bundler/setup'
require 'dino'

# Note: If testing with 2 boards connected to the same computer, you want to be
# explicit about which serial device this script must use. The relevant
# Connection call is below, but commented out. Enable it and substitute the approriate
# device  for the board that has the IR emitter connected and dino sketch loaded.
# Open the receiver board in the Arduino IDE's or another serial monitor.
#
connection = Dino::Connection::Serial.new
# connection = Dino::Connection::Serial.new(device: "/dev/ttyACM0")
board = Dino::Board.new(connection)

#
# The IR emitter can be set up on most pins for most boards, but there might be conflicts
# with other hardware or libraries. Try different pins if one doesn't work.
#
ir = Dino::PulseIO::IRTransmitter.new(board: board, pin: 3)

# NEC Raw-Data=0xF708FB04. LSBFIRST, so the binary for each hex digit below is backward.
code =  [ 9000, 4500,                                 # Start bit
          560, 560, 560, 560, 560, 1690, 560, 560,    # 0010 0x4 command
          560, 560, 560, 560, 560, 560, 560, 560,     # 0000 0x0 command
          560, 1690, 560, 1690, 560,560, 560, 1690,   # 1101 0xB command inverted
          560, 1690, 560, 1690, 560, 1690, 560, 1690, # 1111 0xF command inverted
          560, 560, 560, 560, 560, 560, 560, 1690,    # 0001 0x8 address
          560, 560, 560, 560, 560, 560, 560, 560,     # 0000 0x0 address
          560, 1690, 560, 1690, 560, 1690, 560, 560,  # 1110 0x7 address inverted
          560, 1690, 560, 1690, 560, 1690, 560, 1690, # 1111 0xF address inverted
          560]                                        # Stop bit

ir.emit(code)
board.finish_write
