require 'spec_helper'

module Dino
  module Components
    module Basic
      describe AnalogOutput do
      	include BoardMock
      	let(:options) { { pin: '9', board: board } }
        subject { AnalogOutput.new(options) }

      	describe '#analog_write' do
          it 'should update the @state instance variable and call #analog_write on the board' do
            expect(board).to receive(:analog_write).with(subject.pin, 128).once

            subject.analog_write(128)
            expect(subject.state).to eq(128)
          end
        end

        describe '#write' do
          it 'should call #digital_write if value is HIGH' do
            expect(subject).to receive(:digital_write).with(board.high)
            subject.write(board.high)
          end


          it 'should call #digital_write if value is LOW' do
            expect(subject).to receive(:digital_write).with(board.low)
            subject.write(board.low)
          end

          it 'should call #analog_write if value is anything else' do
            expect(subject).to receive(:analog_write).with(128)
            subject.write(128)
          end
        end
      end
    end
  end
end
