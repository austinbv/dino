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

      it 'should define the logic properly' do
        subject.should_receive(:analog_resolution=).with(8)

        subject.send(:initialize, io_mock)
        subject.high.should == 255
        subject.low.should == 0
      end
    end

    describe '#update' do
      context 'when the given pin connects to input hardware part' do
        it 'should call update with the message on the part' do
          part = mock(:part, pin: 7, pullup: nil)
          subject.add_input_hardware(part)
          other_part = mock(:part, pin: 9, pullup: nil)
          subject.add_input_hardware(other_part)

          part.should_receive(:update).with('wake up!')
          subject.update(7, 'wake up!')
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

    describe '#input_hardware' do
      it 'should initialize as empty' do
        subject.input_hardware.should == []
      end
    end

    describe '#add_input_hardware' do
      it 'should add digital hardware to the board' do
        subject.add_input_hardware(mock1 = mock(:part1, pin: 12, pullup: nil))
        subject.add_input_hardware(mock2 = mock(:part2, pin: 14, pullup: nil))
        subject.input_hardware.should =~ [mock1, mock2]
      end

      it 'should set the mode for the given pin to "in"' do
        subject.should_receive(:set_pin_mode).with(12, :in, nil)
        subject.add_input_hardware(mock(:part1, pin: 12, pullup: nil))
      end
    end

    describe '#remove_input_hardware' do
      it 'should remove the given part from the hardware of the board and stop listening' do
        mock = mock(:part1, pin: 12, pullup: nil)
        subject.add_input_hardware(mock)

        subject.should_receive(:stop_listener).with(12)
        subject.remove_input_hardware(mock)
        
        subject.input_hardware.should == []
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
    end

    describe '#digital_write' do
      it 'should write the value to the right pin' do
        io_mock.should_receive(:write).with(Dino::Message.encode(command: 1, pin: 1, value: 3))
        subject.digital_write(01, 003)
      end
    end

    describe '#digital_read' do
      it 'should tell the board to read once from the given pin' do
        io_mock.should_receive(:write).with(Dino::Message.encode(command: 2, pin: 13))
        subject.digital_read(13)
      end
    end

    describe '#analog_write' do
      it 'should append a append a write to the pin and value' do
        io_mock.should_receive(:write).with(Dino::Message.encode(command: 3, pin: 1, value: 3))
        subject.analog_write(01, 3)
      end
    end

    describe '#analog_read' do
      it 'should tell the board to read once from the given pin' do
        io_mock.should_receive(:write).with(Dino::Message.encode(command: 4, pin: 13))
        subject.analog_read(13)
      end
    end

    describe '#digital_listen' do
      it 'should tell the board to continuously read from the given pin' do
        io_mock.should_receive(:write).with(Dino::Message.encode(command: 5, pin: 13))
        subject.digital_listen(13)
      end
    end

    describe '#analog_listen' do
      it 'should tell the board to continuously read from the given pin' do
        io_mock.should_receive(:write).with(Dino::Message.encode(command: 6, pin: 13))
        subject.analog_listen(13)
      end
    end

    describe '#stop_listener' do
      it 'should tell the board to stop sending values for the given pin' do
        io_mock.should_receive(:write).with(Dino::Message.encode(command: 7, pin: 13))
        subject.stop_listener(13)
      end
    end

    describe '#set_pin_mode' do
      it 'should send a value of 0 if the pin mode is set to out' do
        io_mock.should_receive(:write).with(Dino::Message.encode(command: 0, pin: 13, value: 0))
        subject.set_pin_mode(13, :out)
      end

      it 'should send a value of 1 if the pin mode is set to in' do
        io_mock.should_receive(:write).with(Dino::Message.encode(command: 0, pin: 13, value: 1))
        subject.set_pin_mode(13, :in)
      end

      it 'should set the pullup correctly if mode is in' do
        subject.should_receive(:set_pullup).with(13, nil)
        subject.set_pin_mode(13, :in)
      end

      it 'shouldnt affect the pullup if mode is out' do
        subject.should_not_receive(:set_pullup).with(13, nil)
        subject.set_pin_mode(13, :out)
      end
    end

    describe '#set_pullup' do
      it 'should write high if pullup is enabled' do
        io_mock.should_receive(:write).with(Dino::Message.encode(command: 1, pin: 13, value: subject.high))
        subject.set_pullup(13, true)
      end

      it 'should write low if pullup is disabled' do
        io_mock.should_receive(:write).with(Dino::Message.encode(command: 1, pin: 13, value: subject.low))
        subject.set_pullup(13, false)
      end
    end

    describe '#convert_pin' do
      before(:each) { subject.instance_variable_set(:@analog_zero, 14) }

      it 'should convert alphanumeric pins to numbers' do
        subject.convert_pin('A1').should == 15
      end

      it 'should leave numeric pins alone' do
        subject.convert_pin('13').should == 13
      end
    end
  end
end
