require 'spec_helper'

module Dino
  module Components
    module Basic
      describe DigitalOutput do
        include BoardMock
        let(:options) { { pin: '13', board: board } }
        subject { DigitalOutput.new(options) }

        describe '#after_initialize' do
          it 'should set mode to out and go low' do
            board.should_receive(:digital_write).with(13, board.low)
            DigitalOutput.new(options)
          end
        end

        describe '#digital_write' do
          it 'should update the @state instance variable and call #digital_write on the board' do
            subject
            board.should_receive(:digital_write).with(subject.pin, board.high).once
            subject.digital_write(board.high)
            subject.state.should == board.high
          end
        end

        describe '#high' do
          it 'should call #digital_write with HIGH' do
            subject.should_receive(:digital_write).with(board.high)
            subject.high
          end
        end

        describe '#low' do
          it 'should call #digital_write with LOW' do
            subject.should_receive(:digital_write).with(board.low)
            subject.low
          end
        end

        describe '#toggle' do
          it 'should call high if currently LOW' do
            subject.low
            subject.should_receive(:high)

            subject.toggle
          end

          it 'should call LOW if anything else' do
            subject.high
            subject.should_receive(:low)

            subject.toggle
          end
        end
      end
    end
  end
end
