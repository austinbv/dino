#
# Example using a rotary encoder to control audio output volume on a Mac.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::Board::Connection::Serial.new)
encoder = Dino::DigitalIO::RotaryEncoder.new  board: board,
                                              pins:{ clock: 4, data: 5 },
                                              divider: 1,                # (default) read approx every divider ms
                                              steps_per_revolution: 30   # (default)

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

encoder.add_callback do |update|
  # Increase by 2% for every step so it responds faster.
  value = (volume.get + (update[:change] * 2))
  value = 0 if value < 0
  value = 100 if value > 100
  volume.set(value)
  current_volume = volume.get
  puts "Current volume: #{current_volume}%"
end

sleep
