require 'spec_helper'

module Dino
  module Components
    describe RgbLed do
      let(:board) { mock(:board, analog_write: true, set_pin_mode: true) }
      let(:pins) { {red: 1, green: 2, blue: 3} }
      let(:rgb) { RgbLed.new(pins: pins, board: board)}

      describe '#initialize' do
        it 'should raise if it does not receive a pin' do
          expect {
            RgbLed.new(board: 'a board')
          }.to raise_exception
        end

        it 'should raise if it does not receive a board' do
          expect {
            RgbLed.new(pins: pins)
          }.to raise_exception
        end

        it 'should set the pin to out' do
          board.should_receive(:set_pin_mode).with(1, :out, nil)
          board.should_receive(:set_pin_mode).with(2, :out, nil)
          board.should_receive(:set_pin_mode).with(3, :out, nil)

          RgbLed.new(pins: pins, board: board)
        end

        it 'should set the pin to low' do
          board.should_receive(:analog_write).with(1, Board::LOW)
          board.should_receive(:analog_write).with(2, Board::LOW)
          board.should_receive(:analog_write).with(3, Board::LOW)

          RgbLed.new(pins: pins, board: board)
        end
      end

      describe '#red' do
        it 'should set red to high, blue and green to low' do
          board.should_receive(:analog_write).with(1, Board::HIGH)
          board.should_receive(:analog_write).with(2, Board::LOW)
          board.should_receive(:analog_write).with(3, Board::LOW)
          rgb.red
        end
      end

      describe '#green' do
        it 'should set green to high, red and blue to low' do
          board.should_receive(:analog_write).with(1, Board::LOW)
          board.should_receive(:analog_write).with(2, Board::HIGH)
          board.should_receive(:analog_write).with(3, Board::LOW)
          rgb.green
        end
      end

      describe '#blue' do
        it 'should set blue to high, red and green to low' do
          board.should_receive(:analog_write).with(1, Board::LOW)
          board.should_receive(:analog_write).with(2, Board::LOW)
          board.should_receive(:analog_write).with(3, Board::HIGH)
          rgb.blue
        end
      end

      describe '#cyan' do
        it 'should set blue and green to high, red to low' do
          board.should_receive(:analog_write).with(1, Board::LOW)
          board.should_receive(:analog_write).with(2, Board::HIGH)
          board.should_receive(:analog_write).with(3, Board::HIGH)
          rgb.cyan
        end
      end

      describe '#yellow' do
        it 'should set red and green to high, blue to low' do
          board.should_receive(:analog_write).with(1, Board::HIGH)
          board.should_receive(:analog_write).with(2, Board::HIGH)
          board.should_receive(:analog_write).with(3, Board::LOW)
          rgb.yellow
        end
      end

      describe '#magenta' do
        it 'should set red and blue to high, green to low' do
          board.should_receive(:analog_write).with(1, Board::HIGH)
          board.should_receive(:analog_write).with(2, Board::LOW)
          board.should_receive(:analog_write).with(3, Board::HIGH)
          rgb.magenta
        end
      end

      describe '#white' do
        it 'should set all to high' do
          board.should_receive(:analog_write).with(1, Board::HIGH)
          board.should_receive(:analog_write).with(2, Board::HIGH)
          board.should_receive(:analog_write).with(3, Board::HIGH)
          rgb.white
        end
      end

      describe '#off' do
        it 'should set all to low' do
          board.should_receive(:analog_write).with(1, Board::LOW)
          board.should_receive(:analog_write).with(2, Board::LOW)
          board.should_receive(:analog_write).with(3, Board::LOW)
          rgb.off
        end
      end

      describe '#blinky' do
        it 'should set blue to high, red and green to low' do
          Array.any_instance.should_receive(:cycle).and_yield(:red).and_yield(:green).and_yield(:blue)
          rgb.should_receive(:red)
          rgb.should_receive(:green)
          rgb.should_receive(:blue)
          rgb.blinky
        end
      end
    end
  end
end
