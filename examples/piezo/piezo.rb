#
# Example of playing a melody on a piezoelectric buzzer.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)
buzzer = Dino::Components::Piezo.new(board: board, pin: 9)

C4 = 262
D4 = 294
E4 = 330

notes = [
        [E4, 1], [D4, 1], [C4, 1], [D4, 1], [E4, 1], [E4, 1], [E4, 2],
        [D4, 1], [D4, 1], [D4, 2],          [E4, 1], [E4, 1], [E4, 2],
        [E4, 1], [D4, 1], [C4, 1], [D4, 1], [E4, 1], [E4, 1], [E4, 1], [E4, 1],
        [D4, 1], [D4, 1], [E4, 1], [D4, 1], [C4, 4],
        ]
        
bpm = 240
beat_time = 60.to_f / bpm

notes.each do |note|
  # Note
  buzzer.tone(note[0])
  sleep note[1] * beat_time
end

buzzer.stop
board.finish_write
