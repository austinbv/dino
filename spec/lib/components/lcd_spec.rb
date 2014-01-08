require 'spec_helper'

module Dino
  module Components
    describe LCD do
      include BoardMock
      subject { LCD.new board: board, pins: { rs: 12, enable: 11, d4: 5, d5: 4, d6: 3, d7: 2 }, cols: 16, rows: 2 }

      before do
        board.should_receive(:write).with("10..0.12,11,5,4,3,2\n")
        board.should_receive(:write).with("10..1.16,2\n")
      end

      describe '#clear' do
        it 'clears the display' do
          board.should_receive(:write).with Dino::Message.encode(command: 10, value: 2)
          subject.clear
        end
      end

      describe '#home' do
        it 'Moves the cursor to the first position' do
          board.should_receive(:write).with Dino::Message.encode(command: 10, value: 3)
          subject.home
        end
      end

      describe '#set_cursor' do
        it 'moves the cursor to the given position' do
          board.should_receive(:write).with Dino::Message.encode(command: 10, value: 4, aux_message: "0,1")
          subject.set_cursor(0,1)
        end
      end

      describe '#puts' do
        it 'prints a string in the display' do
          board.should_receive(:write).with Dino::Message.encode(command: 10, value: 5, aux_message: "AB")
          subject.puts("AB")
        end
      end

      describe '#show_cursor' do
        it 'shows the cursor' do
          board.should_receive(:write).with Dino::Message.encode(command: 10, value: 6)
          subject.show_cursor
        end
      end

      describe '#hide_cursor' do
        it 'hides the cursor' do
          board.should_receive(:write).with Dino::Message.encode(command: 10, value: 7)
          subject.hide_cursor
        end
      end

      describe '#blink' do
        it 'shows a blinking cursor' do
          board.should_receive(:write).with Dino::Message.encode(command: 10, value: 8)
          subject.blink
        end
      end

      describe '#no_blink' do
        it 'stops a blinking cursor' do
          board.should_receive(:write).with Dino::Message.encode(command: 10, value: 9)
          subject.no_blink
        end
      end

      describe '#on' do
        it 'turn on the display' do
          board.should_receive(:write).with Dino::Message.encode(command: 10, value: 10)
          subject.on
        end
      end

      describe '#off' do
        it 'turn off the display' do
          board.should_receive(:write).with Dino::Message.encode(command: 10, value: 11)
          subject.off
        end
      end

      describe '#scroll_left' do
        it 'move the text in the display one position to the left' do
          board.should_receive(:write).with Dino::Message.encode(command: 10, value: 12)
          subject.scroll_left
        end
      end

      describe '#scroll_right' do
        it 'move the text in the display one position to the right' do
          board.should_receive(:write).with Dino::Message.encode(command: 10, value: 13)
          subject.scroll_right
        end
      end

      describe '#enable_autoscroll' do
        it 'enable autoscroll' do
          board.should_receive(:write).with Dino::Message.encode(command: 10, value: 14)
          subject.enable_autoscroll
        end
      end

      describe '#disable_autoscroll' do
        it 'disable autoscroll' do
          board.should_receive(:write).with Dino::Message.encode(command: 10, value: 15)
          subject.disable_autoscroll
        end
      end

      describe '#left_to_right' do
        it 'set the display writing to start from the left' do
          board.should_receive(:write).with Dino::Message.encode(command: 10, value: 16)
          subject.left_to_right
        end
      end

      describe '#right_to_left' do
        it 'set the display writing to start from the right' do
          board.should_receive(:write).with Dino::Message.encode(command: 10, value: 17)
          subject.right_to_left
        end
      end
    end
  end
end