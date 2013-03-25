require 'spec_helper'

module Dino
  module Components
    describe LCD do
      let(:board) { mock(:board, digital_write: true, set_pin_mode: true) }
      subject { LCD.new board: board }

      describe '#initialize' do
        it 'should raise if it does not receive a board' do
          expect {
            LCD.new()
          }.to raise_exception
        end
      end

      describe '#begin' do
        it 'should initialize the display sending the command 05011602 to the board' do
          board.should_receive(:write).with '05011602'
          subject.should_receive(:sleep).with 2
          subject.begin(16,2)
        end
      end

      describe '#clear' do
        it 'clears the display sending the command 0502 to the board' do
          board.should_receive(:write).with '0502'
          subject.clear
        end
      end

      describe '#home' do
        it 'Moves the cursor to the first position with the command 0503' do
          board.should_receive(:write).with '0503'
          subject.home
        end
      end

      describe '#set_cursor' do
        it 'moves the cursor to the given position sending the command 0504' do
          board.should_receive(:write).with '05040001'
          subject.set_cursor(0,1)
        end
      end

      describe '#write' do
        it 'writes a char with its byte value with the command 0505' do
          board.should_receive(:write).with '0505065'
          subject.write(65)
        end
      end

      describe '#puts' do
        it 'prints a string in the display' do
          board.should_receive(:write).with '0505065'
          board.should_receive(:write).with '0505066'
          subject.puts("AB")
        end
      end

      describe '#show_cursor' do
        it 'shows the cursor with the command 0506' do
          board.should_receive(:write).with '0506'
          subject.show_cursor
        end
      end

      describe '#hide_cursor' do
        it 'hides the cursor with the command 0507' do
          board.should_receive(:write).with '0507'
          subject.hide_cursor
        end
      end

      describe '#blink' do
        it 'shows a blinking cursor with the command 0508' do
          board.should_receive(:write).with '0508'
          subject.blink
        end
      end

      describe '#no_blink' do
        it 'stops a blinking cursor with the command 0509' do
          board.should_receive(:write).with '0509'
          subject.no_blink
        end
      end

      describe '#on' do
        it 'turn on the display with the command 0510' do
          board.should_receive(:write).with '0510'
          subject.on
        end
      end

      describe '#off' do
        it 'turn off the display with the command 0511' do
          board.should_receive(:write).with '0511'
          subject.off
        end
      end

      describe '#scroll_left' do
        it 'move the text in the display one position to the left  the command 0512' do
          board.should_receive(:write).with '0512'
          subject.scroll_left
        end
      end

      describe '#scroll_right' do
        it 'move the text in the display one position to the right  the command 0513' do
          board.should_receive(:write).with '0513'
          subject.scroll_right
        end
      end

      describe '#enable_autoscroll' do
        it 'enable autoscroll with the command 0514' do
          board.should_receive(:write).with '0514'
          subject.enable_autoscroll
        end
      end

      describe '#disable_autoscroll' do
        it 'disable autoscroll with the command 0515' do
          board.should_receive(:write).with '0515'
          subject.disable_autoscroll
        end
      end

      describe '#left_to_right' do
        it 'set the display writing to start from the left with the command 0516' do
          board.should_receive(:write).with '0516'
          subject.left_to_right
        end
      end

      describe '#right_to_left' do
        it 'set the display writing to start from the right with the command 0517' do
          board.should_receive(:write).with '0517'
          subject.right_to_left
        end
      end
    end
  end
end
