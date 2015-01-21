require 'smalrubot'

Smalrubot.debug_mode = true
board = Smalrubot::Board.new(Smalrubot::TxRx::Serial.new)

=begin
board.digital_write(13, 255)
sleep(1)
board.digital_write(13, 0)
=end

=begin
10.times do
  p board.analog_read(0)
  sleep(0.5)
end
=end

=begin
10.times do
  p board.digital_read(3)
  p board.digital_read(4)
  sleep(0.5)
end
=end
