require 'spec_helper'

module Dino
  module Components
    describe Stepper do
      let(:board) { mock(:board, digital_write: true, set_pin_mode: true) }

      describe '#initialize' do
        it 'should raise if it does not receive a step pin' do
          expect {
            Stepper.new(board: board)
          }.to raise_exception
        end

        it 'should raise if it does not receive a direction pin' do
          expect {
            Stepper.new(board: board)
          }.to raise_exception
        end

        it 'should raise if it does not receive a board' do
          expect {
            Stepper.new(pins: {step: 12, direction: 13})
          }.to raise_exception
        end

        it 'should set the pins to out' do
          board.should_receive(:set_pin_mode).with(13, :out, nil)
          board.should_receive(:set_pin_mode).with(12, :out, nil)
          Stepper.new(pins: {step: 13, direction: 12}, board: board)
        end

        it 'should set the step pin to low' do
          board.should_receive(:digital_write).with(13, Board::LOW)
          Stepper.new(pins: {step: 13, direction: 12}, board: board)
        end
      end

      describe '#step_cc' do
        it 'should send a high to the board with the pin' do
          @stepper = Stepper.new(pins: {step: 13, direction: 12}, board: board)
          board.should_receive(:digital_write).with(12, Board::HIGH)
          board.should_receive(:digital_write).with(13, Board::HIGH)
          board.should_receive(:digital_write).with(13, Board::LOW)
          @stepper.step_cc
        end
      end

      describe '#step_cw' do
        it 'should send a high to the board with the pin' do
          @stepper = Stepper.new(pins: {step: 13, direction: 12}, board: board)
          board.should_receive(:digital_write).with(12, Board::LOW)
          board.should_receive(:digital_write).with(13, Board::HIGH)
          board.should_receive(:digital_write).with(13, Board::LOW)
          @stepper.step_cw
        end
      end
    end
  end
end
