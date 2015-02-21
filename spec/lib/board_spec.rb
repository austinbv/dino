require 'spec_helper'

module Dino
  describe Dino::Board do
    def io_mock(methods = {})
      @io ||= double(:io, {add_observer: true, handshake: 14, write: true, read: true, write: nil}.merge(methods))
    end

    subject { Board.new(io_mock) }

    describe '#initialize' do
      it 'should take an io class' do
        expect {
          Board.new(io_mock)
        }.to_not raise_exception
      end

      it 'should observe the io' do
        expect(io_mock).to receive(:add_observer).with(subject)
        subject.send(:initialize, io_mock)
      end

      it 'should initiate the handshake' do
        io_mock.should_receive(:handshake)
        subject
      end

      it 'should define the logic properly' do
        expect(subject).to receive(:analog_resolution=).with(8)
        subject.send(:initialize, io_mock)
        expect(subject.high).to equal(255)
        expect(subject.low).to equal(0)
      end
    end

    describe '#update' do
      context 'when a component is connected to the pin' do
        it 'should call update with the message on the component' do
          part = double(:part, pin: 7, pullup: nil)
          subject.add_component(part)
          other_part = double(:part, pin: 9, pullup: nil)
          subject.add_component(other_part)

          part.should_receive(:update).with('wake up!')
          subject.update(7, 'wake up!')
        end
      end

      context 'when a component is not connected to the pin' do
        it 'should not do anything' do
          expect {
            subject.update(5, 'wake up!')
          }.to_not raise_exception
        end
      end
    end

    describe '#add_component' do
      it 'should add the component to the board' do
        subject.add_component(mock1 = double(:part1, pin: 12, pullup: nil))
        subject.add_component(mock2 = double(:part2, pin: 14, pullup: nil))
        subject.components.should =~ [mock1, mock2]
      end
    end

    describe '#remove_component' do
      it 'should remove the given part from the hardware of the board and stop listening' do
        mock = double(:part1, pin: 12, pullup: nil)
        subject.add_component(mock)

        subject.should_receive(:stop_listener).with(12)
        subject.remove_component(mock)

        subject.components.should == []
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

    #
    # Board commands
    #
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
    end

    describe '#set_pullup' do
      it 'should write high if pullup is enabled' do
        expect(io_mock).to receive(:write).with(Dino::Message.encode(command: 1, pin: 13, value: subject.high))
        subject.set_pullup(13, true)
      end

      it 'should write low if pullup is disabled' do
        expect(io_mock).to receive(:write).with(Dino::Message.encode(command: 1, pin: 13, value: subject.low))
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
