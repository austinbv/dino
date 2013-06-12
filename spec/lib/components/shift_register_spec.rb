require 'spec_helper'

module Dino
  module Components
    describe ShiftRegister do
      let(:txrx) { mock(:txrx, add_observer: true, handshake: 14, write: true, read: true) }
      let(:board) { Board.new(txrx) }
      let(:options) { { board: board, pins: {clock: 12, data: 11, latch: 8} } }
      subject { ShiftRegister.new(options)  }

      describe '#initialize' do
        it 'should create a BaseOutput instance for each pin' do
          subject.clock.class.should == Core::BaseOutput
          subject.latch.class.should == Core::BaseOutput
          subject.data.class.should == Core::BaseOutput
        end
      end

      describe '#write' do
        before(:each) { subject }

        it 'should write a single byte as value and clock pin as aux to the data pin' do
          subject.latch.should_receive(:digital_write).with(Board::LOW)
          board.should_receive(:write).with "11.11.255.12\n"
          subject.latch.should_receive(:digital_write).with(Board::HIGH)

          subject.write(255)
        end

        it 'should write an array of bytes as value and clock pin as aux to the data pin' do
          subject.latch.should_receive(:digital_write).with(Board::LOW)
          board.should_receive(:write).with "11.11.255.12\n"
          board.should_receive(:write).with "11.11.0.12\n"
          subject.latch.should_receive(:digital_write).with(Board::HIGH)

          subject.write([255,0])
        end
      end
    end
  end
end
