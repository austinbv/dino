#
# This is an example of how to use the ssd class
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)
ssd   = Dino::Components::SSD.new(
  board: board,
  pins:  [12,13,3,4,5,10,9],
  anode: 11
)

# Turn off the ssd on exit
trap("SIGINT") { exit !ssd.off }

# Display each new line on the ssd
loop { ssd.display(gets.chomp) }
