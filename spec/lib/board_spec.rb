require 'spec_helper'

module Dino
  describe Dino::Board do
    def io_mock(methods = {})
      @io ||= double(:io, {add_observer: true, handshake: "14,20", write: true, read: true}.merge(methods))
    end

    subject { Board.new(io_mock) }

    describe '#initialize' do
      it 'should require an io object' do
        expect { Board.new() }.to raise_exception
      end

      it 'should observe the io' do
        expect(io_mock).to receive(:add_observer).with(subject)
        subject.send(:initialize, io_mock)
      end

      it 'should initiate the handshake' do
        expect(io_mock).to receive(:handshake)
        subject
      end

      it 'should set @analog_zero' do
        expect(subject.analog_zero).to equal(14)
      end

      it 'should set @dac_zero' do
        expect(subject.dac_zero).to equal(20)
      end

      it 'should set the analog resolution' do
        board = Board.new(io_mock)
        expect(board.low).to equal(0)
        expect(board.high).to equal(255)
      end
    end

    describe '#update' do
      it 'should pass messages from a pin to the right part' do
        subject.add_component(part1 = double(pin: 7))
        subject.add_component(part2 = double(pin: 9))

        expect(part1).to receive(:update).with('wake up!')
        expect(part2).to_not receive(:update).with('wake up!')
        subject.update(7, 'wake up!')
      end

      it 'should silently ignore messages from a pin if there is no part on it' do
        expect { subject.update(5, 'wake up!') }.to_not raise_exception
      end
    end

    describe '#add_component' do
      it 'should put the part in the components array' do
        subject.add_component(part = double)
        expect(subject.components).to include(part)
      end
    end

    describe '#remove_component' do
      it 'should remove the part from the components array and stop listening' do
        subject.add_component(part = double(pin: 12))
        expect(subject).to receive(:stop_listener).with(12)
        subject.remove_component(part)
        expect(subject.components).to be_empty
      end
    end

    describe '#start_read' do
      it 'should tell the io to read' do
        expect(io_mock).to receive(:read)
        subject.start_read
      end
    end

    describe '#stop_read' do
      it 'should tell the io to read' do
        expect(io_mock).to receive(:close_read)
        subject.stop_read
      end
    end

    describe '#write' do
      it 'should call #write on the io with the message' do
        expect(io_mock).to receive(:write).with('message')
        subject.write('message')
      end
    end

    describe '#convert_pin' do
      before(:each) { subject.instance_variable_set(:@analog_zero, 14) }

      it 'should leave numeric pins as is' do
        expect(subject.convert_pin '13').to equal(13)
      end

      it 'should convert analog pins to numeric form' do
        expect(subject.convert_pin 'A1').to equal(15)
      end

      it 'should convert dac pins to numeric form' do
        expect(subject.convert_pin 'DAC1').to equal(21)
      end

      it 'should raise if trying to convert a dac pin and the board has none' do
        subject.instance_variable_set(:@dac_zero, nil)
        expect { subject.convert_pin 'DAC1' }.to raise_exception(/dac/i)
      end

      it 'should raise if trying to convert a wrongly formatted pin' do
        expect { subject.convert_pin 'ADC1' }.to raise_exception(/incorrect/i)
      end
    end

    #
    # Board API Tests
    #
    describe '#set_pin_mode' do
      it 'should send a value of 0 if the pin mode is set to out' do
        expect(io_mock).to receive(:write).with(Dino::Message.encode(command: 0, pin: 13, value: 0))
        subject.set_pin_mode(13, :out)
      end

      it 'should send a value of 1 if the pin mode is set to in' do
        expect(io_mock).to receive(:write).with(Dino::Message.encode(command: 0, pin: 13, value: 1))
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

    describe '#digital_write' do
      it 'should digitalWrite the value to the pin' do
        expect(io_mock).to receive(:write).with(Dino::Message.encode command: 1, pin: 1, value: 255)
        subject.digital_write(01, 255)
      end
    end

    describe '#digital_read' do
      it 'should digitalRead once from the given pin' do
        expect(io_mock).to receive(:write).with(Dino::Message.encode command: 2, pin: 13)
        subject.digital_read(13)
      end
    end

    describe '#analog_write' do
      it 'should analogWrite the value to the pin' do
        expect(io_mock).to receive(:write).with(Dino::Message.encode command: 3, pin: 1, value: 3)
        subject.analog_write(01, 3)
      end
    end

    describe '#analog_read' do
      it 'should analogRead once from the given pin' do
        expect(io_mock).to receive(:write).with(Dino::Message.encode command: 4, pin: 13)
        subject.analog_read(13)
      end
    end

    describe '#digital_listen' do
      it 'should start listening for a digital signal on the given pin' do
        expect(io_mock).to receive(:write).with(Dino::Message.encode command: 5, pin: 13)
        subject.digital_listen(13)
      end
    end

    describe '#analog_listen' do
      it 'should start listening for an analog signal on the given pin' do
        expect(io_mock).to receive(:write).with(Dino::Message.encode command: 6, pin: 13)
        subject.analog_listen(13)
      end
    end

    describe '#stop_listener' do
      it 'should stop listening for any signal on the given pin' do
        expect(io_mock).to receive(:write).with(Dino::Message.encode command: 7, pin: 13)
        subject.stop_listener(13)
      end
    end

    describe '#analog_resolution=' do
      it 'should tell the board to change the resolution' do
        expect(io_mock).to receive(:write).with(Dino::Message.encode command: 96, value: 10)
        subject.analog_resolution = 10
      end

      it 'should set @bits' do
        subject.analog_resolution = 12
        expect(subject.instance_variable_get(:@bits)).to equal(12)
      end

      it 'should set @high and @low correctly' do
        subject.analog_resolution = 8
        expect(subject.low).to equal(0)
        expect(subject.high).to equal(255)

        subject.analog_resolution = 10
        expect(subject.high).to equal(1023)
      end
    end
  end
end
