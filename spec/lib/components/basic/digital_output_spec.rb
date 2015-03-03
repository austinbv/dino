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
            expect(board).to receive(:digital_write).with(13, board.low)
            subject
          end
        end

        describe '#digital_write' do
          it 'should update the @state instance variable and call #digital_write on the board' do
            subject
            expect(board).to receive(:digital_write).with(subject.pin, board.high).once
            subject.digital_write(board.high)
            expect(subject.state).to eq(board.high)
          end
        end

        describe '#high' do
          it 'should call #digital_write with HIGH' do
            expect(subject).to receive(:digital_write).with(board.high)
            subject.high
          end
        end

        describe '#low' do
          it 'should call #digital_write with LOW' do
            expect(subject).to receive(:digital_write).with(board.low)
            subject.low
          end
        end

        describe '#toggle' do
          it 'should call high if currently LOW' do
            subject.low
            expect(subject).to receive(:high)
            subject.toggle
          end

          it 'should call LOW if anything else' do
            subject.high
            expect(subject).to receive(:low)
            subject.toggle
          end
        end
      end
    end
  end
end
