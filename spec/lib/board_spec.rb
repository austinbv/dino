require 'spec_helper'

module Dino
  describe Board do
    def io_mock(methods = {})
      @io ||= mock(:io, {write: nil, add_observer: nil}.merge(methods))
    end

    subject { Board.new(io_mock) }
    before { subject }

    it {should be_kind_of Observable}

    describe '#initialize' do
      it 'should take a io class' do
        expect {
          Board.new(io_mock)
        }.to_not raise_exception
      end

      it 'should send 8 bits first if this is the first write' do
        io_mock.should_receive(:write).with('00000000')
        Board.new(io_mock)
      end
    end

    describe '#start_read' do
      it 'should tell the io to read' do
        io_mock(read: nil).should_receive(:read)
        Board.new(io_mock).start_read
      end
    end

    describe '#stop_read' do
      it 'should tell the io to read' do
        io_mock(close_read: nil).should_receive(:close_read)
        Board.new(io_mock).stop_read
      end
    end

    describe '#write' do
      it 'should return true if the write succeeds' do
        board = Board.new(io_mock(write: nil))
        board.write("message").should == true
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
        Board.new(io_mock).digital_write(01, 003)
      end
    end

    describe '#digital_read' do
      it 'should tell the board to start reading from the given pin' do
        io_mock.should_receive(:write).with('!0213000.')
        subject.digital_read(13)
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
        expect { subject.normalize_pin(1000) }.to raise_exception 'pins can only be two digits'
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

    describe '#set_pin_mode' do
      it 'should send a value of 1 if the pin mode is set to out' do
        io_mock.should_receive(:write).with('!0013001.')
        subject.set_pin_mode(13, :out)
      end

      it 'should send a value of 0 if the pin mode is set to in' do
        io_mock.should_receive(:write).with('!0013000.')
        subject.set_pin_mode(13, :in)
      end
    end

    describe '#set_debug' do
      it 'should set the boards debug on when passed on' do
        io_mock.should_receive(:write).with('!9900001.')
        subject.set_debug(:on)
      end

      it 'should set the boards debug off when passed off' do
        io_mock.should_receive(:write).with('!9900000.')
        subject.set_debug(:off)
      end
    end

    it 'should have tests for observing the io'
  end
end
