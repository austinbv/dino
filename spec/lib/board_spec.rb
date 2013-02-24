require 'spec_helper'

module Dino
  describe Dino::Board do
    def io_mock(methods = {})
      @io ||= mock(:io, {write: nil, add_observer: nil, flush_read: nil, handshake: "14"}.merge(methods))
    end

    subject { Board.new(io_mock) }

    describe '#initialize' do
      it 'should take an io class' do
        expect {
          Board.new(io_mock)
        }.to_not raise_exception
      end

      it 'should observe the io' do
        io_mock.should_receive(:add_observer).with(subject)
        subject.send(:initialize, io_mock)
      end

      it 'should initiate the handshake' do
        io_mock.should_receive(:handshake)
        subject
      end
    end

    describe '#update' do
      context 'when the given pin connects to an analog hardware part' do
        it 'should call update with the message on the part' do
          part = mock(:part, pin: 7)
          subject.add_analog_hardware(part)
          other_part = mock(:part, pin: 9)
          subject.add_analog_hardware(other_part)

          part.should_receive(:update).with('wake up!')
          subject.update(7, 'wake up!')
        end
      end

      context 'when the given pin connects to an digital hardware part' do
        it 'should call update with the message on the part' do
          part = mock(:part, pin: 5, pullup: nil)
          subject.add_digital_hardware(part)
          other_part = mock(:part, pin: 11, pullup: nil)
          subject.add_digital_hardware(other_part)

          part.should_receive(:update).with('wake up!')
          other_part.should_not_receive(:update).with('wake up!')

          subject.update(5, 'wake up!')
        end
      end

      context 'when the given pin is not connected' do
        it 'should not do anything' do
          expect {
            subject.update(5, 'wake up!')
          }.to_not raise_exception
        end
      end
    end

    describe '#digital_hardware' do
      it 'should initialize as empty' do
        subject.digital_hardware.should == []
      end
    end

    describe '#analog_hardware' do
      it 'should initialize as empty' do
        subject.analog_hardware.should == []
      end
    end

    describe '#add_digital_hardware' do
      it 'should add digital hardware to the board' do
        subject.add_digital_hardware(mock1 = mock(:part1, pin: 12, pullup: nil))
        subject.add_digital_hardware(mock2 = mock(:part2, pin: 14, pullup: nil))
        subject.digital_hardware.should =~ [mock1, mock2]
      end

      it 'should set the mode for the given pin to "in" and add a digital listener' do
        subject
        subject.should_receive(:write).with("0012001")
        subject.should_receive(:write).with("0112000")
        subject.should_receive(:write).with("0512000")
        subject.add_digital_hardware(mock1 = mock(:part1, pin: 12, pullup: nil))
      end
    end

    describe '#remove_digital_hardware' do
      it 'should remove the given part from the hardware of the board' do
        mock = mock(:part1, pin: 12, pullup: nil)
        subject.add_digital_hardware(mock)
        subject.remove_digital_hardware(mock)
        subject.digital_hardware.should == []
      end
    end

    describe '#add_analog_hardware' do
      it 'should add analog hardware to the board' do
        subject.add_analog_hardware(mock1 = mock(:part1, pin: 12, pullup: nil))
        subject.add_analog_hardware(mock2 = mock(:part2, pin: 14, pullup: nil))
        subject.analog_hardware.should =~ [mock1, mock2]
      end

      it 'should set the mode for the given pin to "in" and add an analog listener' do
        subject
        subject.should_receive(:write).with("0012001")
        subject.should_receive(:write).with("0112000")
        subject.should_receive(:write).with("0612000")
        subject.add_analog_hardware(mock1 = mock(:part1, pin: 12, pullup: nil))
      end
    end

    describe '#remove_analog_hardware' do
      it 'should remove the given part from the hardware of the board' do
        mock = mock(:part1, pin: 12, pullup: nil)
        subject.add_analog_hardware(mock)
        subject.remove_analog_hardware(mock)
        subject.analog_hardware.should == []
      end
    end

    describe '#start_read' do
      it 'should tell the io to read' do
        io_mock.should_receive(:read)
        Board.new(io_mock).start_read
      end
    end

    describe '#stop_read' do
      it 'should tell the io to read' do
        io_mock.should_receive(:close_read)
        Board.new(io_mock).stop_read
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
        subject.digital_read(13)
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
        subject.analog_read(13)
      end
    end

    describe '#digital_listen' do
      it 'should tell the board to continuously read from the given pin' do
        io_mock.should_receive(:write).with('!0513000.')
        subject.digital_listen(13)
      end
    end

    describe '#analog_listen' do
      it 'should tell the board to continuously read from the given pin' do
        io_mock.should_receive(:write).with('!0613000.')
        subject.analog_listen(13)
      end
    end

    describe '#stop_listener' do
      it 'should tell the board to stop sending values for the given pin' do
        io_mock.should_receive(:write).with('!0713000.')
        subject.stop_listener(13)
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
