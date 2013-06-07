require 'spec_helper'

module Dino
  module Components
    describe ShiftRegister do
      let(:board) { mock(:board, digital_write: true, set_pin_mode: true) }

      subject { ShiftRegister.new board: board, pins: {clock: 12, data: 11, latch: 8} }

      describe '#initialize' do
        it 'should set all pins to out and low' do
          board.should_receive(:set_pin_mode).with(12, :out, nil)
          board.should_receive(:set_pin_mode).with(11, :out, nil)
          board.should_receive(:set_pin_mode).with(8,  :out, nil)
          board.should_receive(:digital_write).with(12, Board::LOW)
          board.should_receive(:digital_write).with(11, Board::LOW)
          board.should_receive(:digital_write).with(8,  Board::LOW)

          ShiftRegister.new(pins: {clock: 12, data: 11, latch: 8}, board: board)
        end
      end

      describe '#latch_off' do
        it 'should set the latch pin low' do
          board.should_receive(:digital_write).with(8, Board::LOW)

          subject.latch_off
        end
      end

      describe '#latch_off' do
        it 'should set the latch pin high' do
          board.should_receive(:digital_write).with(8, Board::HIGH)

          subject.latch_on
        end
      end

      describe '#write' do
        it 'should write a single byte as value and clock pin as aux to the data pin' do
          board.should_receive(:convert_pin).with(11) { |pin| pin }
          board.should_receive(:convert_pin).with(12) { |pin| pin }
          board.should_receive(:write).with "11.11.255.12\n"

          subject.write(255)
        end

        it 'should write an array of bytes as value and clock pin as aux to the data pin' do
          board.should_receive(:convert_pin).with(11) { |pin| pin }
          board.should_receive(:convert_pin).with(12) { |pin| pin }
          board.should_receive(:write).with "11.11.255.12\n"
          board.should_receive(:write).with "11.11.0.12\n"

          subject.write([255,0])
        end
      end
    end
  end
end
