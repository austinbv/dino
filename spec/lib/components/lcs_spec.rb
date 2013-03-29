require 'spec_helper'

module Dino
  module Components
    describe LCD do
      let(:board) { mock(:board, digital_write: true, set_pin_mode: true) }
      subject { LCD.new board: board, pins: '12,11,5,4,3,2' }

      before do
        board.should_receive(:write).with("10...12,11,5,4,3,2\n")
      end

      describe '#begin' do
        it 'should initialize the display sending the command "11..1.16,2\n" to the board' do
          board.should_receive(:write).with "11..1.16,2\n"
          subject.should_receive(:sleep).with 2
          subject.begin(16,2)
        end
      end

      describe '#clear' do
        it 'clears the display sending the command "11..2\n" to the board' do
          board.should_receive(:write).with "11..2\n"
          subject.clear
        end
      end

      describe '#home' do
        it 'Moves the cursor to the first position with the command "11..3\n"' do
          board.should_receive(:write).with "11..3\n"
          subject.home
        end
      end

      describe '#set_cursor' do
        it 'moves the cursor to the given position sending the command "11..4.0,1\n"' do
          board.should_receive(:write).with "11..4.0,1\n"
          subject.set_cursor(0,1)
        end
      end

      describe '#puts' do
        it 'prints a string in the display' do
          board.should_receive(:write).with "11..5.AB\n"
          subject.puts("AB")
        end
      end

      describe '#show_cursor' do
        it 'shows the cursor with the command "11..6\n"' do
          board.should_receive(:write).with "11..6\n"
          subject.show_cursor
        end
      end

      describe '#hide_cursor' do
        it 'hides the cursor with the command "11..7\n"' do
          board.should_receive(:write).with "11..7\n"
          subject.hide_cursor
        end
      end

      describe '#blink' do
        it 'shows a blinking cursor with the command "11..8\n"' do
          board.should_receive(:write).with "11..8\n"
          subject.blink
        end
      end

      describe '#no_blink' do
        it 'stops a blinking cursor with the command "11..9\n"' do
          board.should_receive(:write).with "11..9\n"
          subject.no_blink
        end
      end

      describe '#on' do
        it 'turn on the display with the command "11..10\n"' do
          board.should_receive(:write).with "11..10\n"
          subject.on
        end
      end

      describe '#off' do
        it 'turn off the display with the command "11..11\n"' do
          board.should_receive(:write).with "11..11\n"
          subject.off
        end
      end

      describe '#scroll_left' do
        it 'move the text in the display one position to the left  the command "11..12\n"' do
          board.should_receive(:write).with "11..12\n"
          subject.scroll_left
        end
      end

      describe '#scroll_right' do
        it 'move the text in the display one position to the right  the command "11..13\n"' do
          board.should_receive(:write).with "11..13\n"
          subject.scroll_right
        end
      end

      describe '#enable_autoscroll' do
        it 'enable autoscroll with the command "11..14\n"' do
          board.should_receive(:write).with "11..14\n"
          subject.enable_autoscroll
        end
      end

      describe '#disable_autoscroll' do
        it 'disable autoscroll with the command "11..15\n"' do
          board.should_receive(:write).with "11..15\n"
          subject.disable_autoscroll
        end
      end

      describe '#left_to_right' do
        it 'set the display writing to start from the left with the command "11..16\n"' do
          board.should_receive(:write).with "11..16\n"
          subject.left_to_right
        end
      end

      describe '#right_to_left' do
        it 'set the display writing to start from the right with the command "11..17\n"' do
          board.should_receive(:write).with "11..17\n"
          subject.right_to_left
        end
      end
    end
  end
end
