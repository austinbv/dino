require 'smalrubot'

Smalrubot.debug_mode = true
board = Smalrubot::Board.new(Smalrubot::TxRx::Serial.new)

=begin
board.digital_write(13, 255)
sleep(1)
board.digital_write(13, 0)
=end

10.times do
  p board.analog_read(0)
  sleep(0.5)
end

