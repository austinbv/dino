require 'spec_helper'

module Dino
  module Components
    describe ShiftRegisterOut do
      include BoardMock
      let(:options) { { board: board, pins: {clock: 12, data: 11, latch: 8} } }
      subject { ShiftRegisterOut.new(options)  }

      describe '#initialize' do
        it 'should create a BaseOutput instance for each pin' do
          expect(subject.clock.class).to eq(Basic::DigitalOutput)
          expect(subject.latch.class).to eq(Basic::DigitalOutput)
          expect(subject.data.class).to eq(Basic::DigitalOutput)
        end
      end

      describe '#write' do
        before(:each) { subject }

        it 'should send message for single byte in the request format the board expects' do
          expect(board).to receive(:write).with "22.11.12.#{[8,0,1,255].pack('C*')}\n"

          subject.write(255)
        end

        it 'should send message for array of bytes in the request format the board expects' do
          expect(board).to receive(:write).with "22.11.12.#{[8,0,2,255,0].pack('C*')}\n"

          subject.write([255,0])
        end
      end
    end
  end
end
