#
# This is an example of how to use the ssd class
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::Board::Connection::Serial.new)
ssd   = Dino::LED::SevenSegment.new board: board,
                                    pins:  { cathode: 10, a: 3, b: 4, c: 5, d: 6, e: 7, f: 8, g: 9 }

# Turn off the ssd on exit
trap("SIGINT") { exit !ssd.off }

# Display each new line on the ssd
loop { ssd.display(gets.chomp) }
