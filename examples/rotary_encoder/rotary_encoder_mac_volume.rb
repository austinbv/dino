#
# Example of a smiple rotary encoder polling at ~1ms.
#
# WARNING: This method is not precise at all. Please do not use it for anything
# that requires all steps to be read for precise positioning or high speed.
#
# Works well enough for making knobs like this example though.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)
encoder = Dino::Components::RotaryEncoder.new board: board,
                                              pins:{ clock: 4, data: 5 },
                                              divider: 1, # (default) read approx every divider ms
                                              steps: 30   # (default) steps / revolution

# Set up a pseudo terminal with osascript (AppleScript) in interactive mode.
# Calling a separate script each update is too slow.
class AppleVolumeWrapper
  require 'pty'
  require 'expect'

  def initialize
    @in, @out, pid = PTY.spawn('osascript -i')
    @in.expect(/>> /) # Terminal ready.
  end

  def get
    @out.write("output volume of (get volume settings)\r\n")
    @in.expect(/=> (\d+)\r\n/)[1].to_i
  end

  def set(value)
    @out.write("set volume output volume #{value}\r\n")
    @in.expect(/>> /)
  end
end

volume = AppleVolumeWrapper.new
puts "Current volume: #{volume.get}%"

# Some values from 0-100 aren't applied so the encoder gets stuck in a
# small range if we write every step. Track when a step has no effect
# and apply it later with this.
unused_steps = 0

encoder.add_callback do |update|
  value = volume.get + update[:change] + unused_steps
  value = 0 if value < 0
  value = 100 if value > 100
  volume.set(value)
  unused_steps = value - volume.get
  puts "Current volume: #{volume.get}%"
end

sleep
