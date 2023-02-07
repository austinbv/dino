#
# This is a simple test of the IREmitter (infrared blaster) class.
# It is based on part of "IRtest2" from the included Arduino library:
#   https://github.com/z3t0/Arduino-IRremote/tree/master/examples
#
# To verify your emitter is working, you could flash "IRrecvDump2" from that
# examples directory to a second board. With an IR receiver on the correct pin
# of the board (see https://github.com/z3t0/Arduino-IRremote#hardware-specifications),
# open a serial monitor at 9600 and check that it receives the signal sent by this script.
#
# If you don't have 2 boards, use "IRrecvDump2" to capture a code from a button
# of a remote you have. Copy the raw code (long list of numbers in curly braces),
# from the serial output, replace the curly braces with square brackets, and
# those raw values are now compatible with Ruby and this script.
#
# Flash the dino sketch onto your board and connect the IR emitter.
# Substitute a code you captured for the NEC example below.
# The corresponding action should happen on your device, eg. "Power" on your TV.
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
# TxRx call is below, but commented out. Enable it and substitute the approriate
# device  for the board that has the IR emitter connected and dino sketch loaded.
txrx = Dino::TxRx::Serial.new
# txrx = Dino::TxRx::Serial.new(device: "/dev/ttyACM0")
board = Dino::Board.new(txrx)

# Setting the IR emitter pin is currently unsupported.
# Although the value gets passed to the board, it always uses the default pin
# for your specfic board/chip, as defined by the library (in bold) at:
# https://github.com/z3t0/Arduino-IRremote#hardware-specifications
ir = Dino::Components::IREmitter.new(board: board, pin: 3)

# This is the raw data corresponding to NEC 0x12345678
code = [9000, 4500,
        560, 560, 560, 560, 560, 560, 560, 1690,
        560, 560, 560, 560, 560, 1690, 560, 560,
        560, 560, 560, 560, 560, 1690, 560, 1690,
        560, 560, 560, 1690, 560, 560, 560, 560,
        560, 560, 560, 1690, 560, 560, 560, 1690,
        560, 560, 560, 1690, 560, 1690, 560, 560,
        560, 560, 560, 1690, 560, 1690, 560, 1690,
        560, 1690, 560, 560, 560, 560, 560, 560,
        560]

ir.emit(code)
