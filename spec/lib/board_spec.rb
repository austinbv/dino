require 'spec_helper'

module Smalrubot
  describe Smalrubot::Board do
    def io_mock(methods = {})
      @io ||= double(:io, {write: nil, flush_read: nil, handshake: "14"}.merge(methods))
    end

    subject { Board.new(io_mock) }

    describe '#initialize' do
      it 'should take an io class' do
        expect {
          Board.new(io_mock)
        }.to_not raise_exception
      end

      it 'should initiate the handshake' do
        io_mock.should_receive(:handshake)
        subject
      end
    end

    describe '#write' do
      it 'should return true if the write succeeds' do
        @io = nil
        board = Board.new(io_mock(write: true))
        board.write('message').should == true
      end

      it 'should wrap the message in a ! and a . by default' do
        io_mock.should_receive(:write).with('!hello.')
        subject.write('hello')
      end

      it 'should not wrap the message if no_wrap is set to true' do
        board = Board.new(io_mock)
        io_mock.should_receive(:write).with('hello')
        board.write('hello', no_wrap: true)
      end
    end

    describe '#digital_write' do
      it 'should append a append a write to the pin and value' do
        io_mock.should_receive(:write).with('!0101003.')
        subject.digital_write(01, 003)
      end
    end

    describe '#digital_read' do
      it 'should tell the board to read once from the given pin' do
        io_mock.should_receive(:write).with('!0213000.')
        io_mock.should_receive(:read).with(1).and_return(['13', Smalrubot::Board::HIGH.to_s])
        expect(subject.digital_read(13)).to eq(Smalrubot::Board::HIGH)
      end
    end

    describe '#analog_write' do
      it 'should append a append a write to the pin and value' do
        io_mock.should_receive(:write).with('!0301003.')
        subject.analog_write(01, 003)
      end
    end

    describe '#analog_read' do
      it 'should tell the board to read once from the given pin' do
        io_mock.should_receive(:write).with('!0413000.')
        io_mock.should_receive(:read).with(1).once.and_return(['13', '256'])
        expect(subject.analog_read(13)).to eq(256)
      end
    end

    describe '#set_pin_mode' do
      it 'should send a value of 0 if the pin mode is set to out' do
        io_mock.should_receive(:write).with('!0013000.')
        subject.set_pin_mode(13, :out)
      end

      it 'should send a value of 1 if the pin mode is set to in' do
        io_mock.should_receive(:write).with('!0013001.')
        subject.set_pin_mode(13, :in)
      end
    end

    describe '#handshake' do
      it 'should tell the board to reset to defaults' do
        io_mock.should_receive(:handshake)
        subject.handshake
      end
    end

    describe '#normalize_pin' do
      it 'should normalize numbers so they are two digits' do
        subject.normalize_pin(1).should == '01'
      end

      it 'should not normalize numbers that are already two digits' do
        subject.normalize_pin(10).should == '10'
      end

      it 'should raise if a number larger than two digits are given' do
        expect { subject.normalize_pin(1000) }.to raise_exception 'pin number must be in 0-99'
      end
    end

    describe '#normalize_value' do
      it 'should normalize numbers so they are three digits' do
        subject.normalize_value(1).should == '001'
      end

      it 'should not normalize numbers that are already three digits' do
        subject.normalize_value(10).should == '010'
      end

      it 'should raise if a number larger than three digits are given' do
        expect { subject.normalize_value(1000) }.to raise_exception 'values are limited to three digits'
      end
    end
  end
end
