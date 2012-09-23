require 'spec_helper'

module Dino
  module Components
    describe RgbLed do
      let(:board) { mock(:board, analog_write: true, set_pin_mode: true) }
      let(:pins) { {red: 1, green: 2, blue: 3} }

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
          board.should_receive(:set_pin_mode).with(1, :out)
          board.should_receive(:set_pin_mode).with(2, :out)
          board.should_receive(:set_pin_mode).with(3, :out)

          RgbLed.new(pins: pins, board: board)
        end

        it 'should set the pin to low' do
          board.should_receive(:analog_write).with(1, Board::LOW)
          board.should_receive(:analog_write).with(2, Board::LOW)
          board.should_receive(:analog_write).with(3, Board::LOW)

          RgbLed.new(pins: pins, board: board)
        end
      end
    end
  end
end
