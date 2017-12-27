require 'spec_helper'

module Dino
  module Components
    module Register
      describe ShiftOut do
        include BoardMock
        let(:options) { { board: board, pins: {clock: 12, data: 11, latch: 8} } }
        subject { ShiftOut.new(options)  }

        describe '#initialize' do
          it 'should create a DigitalOutput instance for clock and data pins' do
            expect(subject.clock.class).to eq(Basic::DigitalOutput)
            expect(subject.data.class).to eq(Basic::DigitalOutput)
          end

          it 'should create a Register::Select instance for latch pin' do
            expect(subject.latch.class).to eq(Register::Select)
          end
        end

        describe '#write' do
          before(:each) { subject }

          it 'should send message for single byte in the request format the board expects' do
            expect(board).to receive(:write).with "22.8.1.#{[11,12,0,255].pack('C*')}\n"

            subject.write(255)
          end

          it 'should send message for array of bytes in the request format the board expects' do
            expect(board).to receive(:write).with "22.8.2.#{[11,12,0,255,0].pack('C*')}\n"

            subject.write([255,0])
          end
        end
      end
    end
  end
end
