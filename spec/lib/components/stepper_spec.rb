require 'spec_helper'

module Dino
  module Components
    describe Stepper do
      include BoardMock
      let(:options) { { pins: {step: 9, direction: 10}, board: board } }

      subject { Stepper.new(options) }

      describe '#initialize' do
        it 'should create a BaseOutput instance for each pin' do          
          subject.step.class.should == Basic::DigitalOutput
          subject.direction.class.should == Basic::DigitalOutput
        end
      end

      describe '#step_cc' do
        it 'should send high to the step pin with the direction pin high' do
          subject.direction.should_receive(:digital_write).with(board.high)
          subject.step.should_receive(:digital_write).with(board.high)
          subject.step.should_receive(:digital_write).with(board.low)

          subject.step_cc
        end
      end

      describe '#step_cw' do
        it 'should send high to the board with the direction pin low' do
          subject.direction.should_receive(:digital_write).with(board.low)
          subject.step.should_receive(:digital_write).with(board.high)
          subject.step.should_receive(:digital_write).with(board.low)

          subject.step_cw
        end
      end
    end
  end
end
