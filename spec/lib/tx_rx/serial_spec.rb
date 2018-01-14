require 'spec_helper'

module Dino
  describe TxRx::Serial do
    def mock_tty
      @mock_tty ||= "/dev/mock_serial"
    end

    def mock_serial
      @mock_serial ||= double("serial", read: "", write: nil)
    end

    subject {
      Dino::TxRx::Serial.new
    }

    def io_instance
      subject.send(:io)
    end

    describe '#connect' do
      it 'should use the specified device and baud rate from options hash' do
        expect(::Serial).to receive(:new).with("/dev/ttyACM0", 9600).and_return(mock_serial)
        txrx = Dino::TxRx::Serial.new(device: "/dev/ttyACM0", baud: 9600)
        expect(txrx.send(:io)).to equal mock_serial
      end

      context "on windows" do
        it 'should create a new ::Serial object for the connected COM port if non specified' do
          # Simulate being on Windows
          original_platform = RUBY_PLATFORM
          Constants.redefine(:RUBY_PLATFORM, "mswin", :on => Object)

          # Simulate 3 COM ports with COM2 connected.
          expect_any_instance_of(TxRx::Serial).to receive(:tty_devices).and_return(["COM1", "COM2", "COM3"])
          expect(::Serial).to receive(:new).with("COM1", TxRx::Serial::BAUD).and_raise(RubySerial::Error)
          expect(::Serial).to receive(:new).with("COM2", TxRx::Serial::BAUD).and_return(mock_serial)
          expect(::Serial).to_not receive(:new).with("COM3", TxRx::Serial::BAUD)

          txrx = TxRx::Serial.new
          expect(txrx.send(:io)).to equal(mock_serial)

          # Set platform back to original value
          Constants.redefine(:RUBY_PLATFORM, original_platform, :on => Object)
        end
      end

      context "on *nix" do
        it 'should create a new ::Serial for the first connected tty device if none specified' do
          # Simulate /dev/ttyACM0 connected.
          expect_any_instance_of(TxRx::Serial).to receive(:tty_devices).and_return(['/dev/ttyACM0', '/dev/tty.usbmodem1'])
          expect(::Serial).to receive(:new).with('/dev/ttyACM0', TxRx::Serial::BAUD).and_return(mock_serial)
          expect(::Serial).to_not receive(:new).with('/dev/tty.usbmodem1', TxRx::Serial::BAUD)

          txrx = TxRx::Serial.new
          expect(txrx.send(:io)).to equal(mock_serial)
        end
      end

      it 'should raise SerialConnectError if it cannot connect to a board' do
        allow(::Serial).to receive(:new).and_raise(RubySerial::Error)
        expect { TxRx::Serial.new.send(:io) }.to raise_exception Dino::TxRx::SerialConnectError
      end
    end

    describe '#io_reset' do
      it 'should call flush read, stop read, and start read' do
        expect(subject).to receive(:flush_read).and_return true
        expect(subject).to receive(:stop_read).and_return true
        expect(subject).to receive(:start_read).and_return true
        subject.send(:io_reset)
      end
    end

    describe '#read_and_process' do
      it 'should notify observers on change' do
        expect(subject).to receive(:read).and_return("02:00")
        expect(subject).to receive(:changed).and_return(true)
        expect(subject).to receive(:notify_observers).with('02','00')
        subject.send(:read_and_process)
      end

      it 'should not split messages into more than 2 parts on :' do
        expect(subject).to receive(:read).and_return("02:00:00")
        expect(subject).to receive(:changed).and_return(true)
        expect(subject).to receive(:notify_observers).with('02','00:00')
        subject.send(:read_and_process)
      end
    end

    describe '#start_read' do
      it 'should create a new thread and start looping' do
        expect(Thread).to receive(:new).and_yield.and_return(double("abort_on_exception=" => true))
        expect(subject).to receive(:loop)
        subject.send(:start_read)
      end
    end

    describe '#stop_read' do
      it 'should kill the reading thread' do
        subject.instance_variable_set(:@thread, mock_thread = double)
        expect(Thread).to receive(:kill).with(mock_thread)
        subject.send(:start_read)
        subject.send(:stop_read)
      end
    end

    describe '#write' do
      it 'should write to the device' do
        expect(subject).to receive(:io).at_least(:once).and_return(mock_serial)
        expect(mock_serial).to receive(:write).with('a message')
        subject.write('a message')
      end
      it 'should break up messages larger than the board input buffer'
    end

    describe '#read' do
      before :each do
        expect(subject).to receive(:io).at_least(:once).and_return(mock_serial)
      end

      it 'should read single characters until it hits a newline and strip it' do
        expect(mock_serial).to receive(:read).exactly(5).times.with(1).and_return("l", "i", "n", "e", "\n")
        expect(subject.send(:read)).to eq("line")
      end

      it 'should catch escaped newlines' do
        expect(mock_serial).to receive(:read).exactly(7).times.with(1).and_return("l", "1", "\\", "\n", "l", "2", "\n")
        expect(subject.send(:read)).to eq("l1\nl2")
      end

      it 'should return a blank string if there is just a newline' do
        expect(mock_serial).to receive(:read).exactly(1).times.with(1).and_return("\n")
        expect(subject.send(:read)).to eq("")
      end

      it 'should allow escaped backslashes' do
        expect(io_instance).to receive(:read).exactly(3).times.with(1).and_return("\\", "\\", "\n")
        expect(subject.send(:read)).to eq("\\")
      end
    end

    describe '#handshake' do
      it 'should call #io_reset'
      it 'should write again after timeout'
      it 'should return the value from the ACK'
    end
  end
end
