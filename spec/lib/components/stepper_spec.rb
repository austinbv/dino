require 'spec_helper'

module Dino
  module Components
    describe Stepper do
      include BoardMock
      let(:options) { { pins: {step: 9, direction: 10}, board: board } }

      subject { Stepper.new(options) }

      describe '#initialize' do
        it 'should create a BaseOutput instance for each pin' do
          expect(subject.step.class).to equal(Basic::DigitalOutput)
          expect(subject.direction.class).to equal(Basic::DigitalOutput)
        end
      end

      describe '#step_cc' do
        it 'should send high to the step pin with the direction pin high' do
          expect(subject.direction).to receive(:digital_write).with(board.high)
          expect(subject.step).to receive(:digital_write).with(board.high)
          expect(subject.step).to receive(:digital_write).with(board.low)

          subject.step_cc
        end
      end

      describe '#step_cw' do
        it 'should send high to the board with the direction pin low' do
          expect(subject.direction).to receive(:digital_write).with(board.low)
          expect(subject.step).to receive(:digital_write).with(board.high)
          expect(subject.step).to receive(:digital_write).with(board.low)

          subject.step_cw
        end
      end
    end
  end
end
