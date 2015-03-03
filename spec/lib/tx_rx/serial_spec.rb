require 'spec_helper'

module Dino
  describe TxRx::Serial do
    describe '#connect' do
      it 'should use the specified device and baud rate from options hash' do
        expect(::Serial).to receive(:new).with("/dev/ttyACM0", 9600).and_return(mock_serial = double)
        txrx = Dino::TxRx::Serial.new(device: "/dev/ttyACM0", baud: 9600)
        expect(txrx.io).to equal mock_serial
      end

      context "on windows" do
        it 'should create a new ::Serial object for the connected COM port if non specified' do
          # Simulate being on Windows
          original_platform = RUBY_PLATFORM
          Constants.redefine(:RUBY_PLATFORM, "mswin", :on => Object)

          # Simulate 3 COM ports with COM2 connected.
          expect(subject).to receive(:tty_devices).and_return(["COM1", "COM2", "COM3"])
          expect(::Serial).to receive(:new).with("COM1", TxRx::Serial::BAUD).and_raise
          expect(::Serial).to receive(:new).with("COM2", TxRx::Serial::BAUD).and_return(mock_serial = double)
          expect(::Serial).to_not receive(:new).with("COM3", TxRx::Serial::BAUD)
          expect(subject.io).to equal(mock_serial)

          # Set platform back to original value
          Constants.redefine(:RUBY_PLATFORM, original_platform, :on => Object)
        end
      end

      context "on *nix" do
        it 'should create a new ::Serial for the first connected tty device if none specified' do
          expect(subject).to receive(:tty_devices).and_return(['/dev/ttyACM0', '/dev/tty.usbmodem1'])

          # Simulate /dev/ttyACM0 connected.
          expect(::Serial).to receive(:new).with('/dev/ttyACM0', TxRx::Serial::BAUD).and_return(mock_serial = double)
          expect(::Serial).to_not receive(:new).with('/dev/tty.usbmodem1', TxRx::Serial::BAUD)
          expect(subject.io).to equal(mock_serial)
        end
      end

      it 'should use the existing io instance if set' do
        expect(subject).to receive(:tty_devices).once.and_return(['/dev/tty.ACM0'])
        expect(::Serial).to receive(:new).and_return(mock_serial = double)
        3.times { subject.io }
        subject.io.should == mock_serial
      end

      it 'should raise a BoardNotFound exception if there is no board connected' do
        allow(::Serial).to receive(:new).and_raise
        expect { subject.io }.to raise_exception Dino::TxRx::BoardNotFound
      end
    end

    describe '#_read' do
      it 'should notify observers on change' do
        expect(subject).to receive(:gets).and_return("02:00\n")
        expect(subject).to receive(:changed).and_return(true)
        expect(subject).to receive(:notify_observers).with('02','00')
        subject._read
      end
    end

    describe '#read' do
      it 'should create a new thread and start looping' do
        expect(Thread).to receive(:new).and_yield.and_return(double("abort_on_exception=" => true))
        expect(subject).to receive(:loop)
        subject.read
      end
    end

    describe '#close_read' do
      it 'should kill the reading thread' do
        subject.instance_variable_set(:@thread, mock_thread = double)
        expect(Thread).to receive(:kill).with(mock_thread)
        subject.read
        subject.close_read
      end
    end

    describe '#write' do
      it 'should write to the device' do
        expect(subject).to receive(:io).and_return(mock_serial = double)
        expect(mock_serial).to receive(:write).with('a message')
        subject.write('a message')
      end
    end

    describe '#gets' do
      it 'should read single characters until it hits a newline and strip it' do
        expect(subject).to receive(:io).at_least(:once).and_return(mock_serial = double)
        expect(mock_serial).to receive(:read).exactly(5).times.with(1).and_return("l", "i", "n", "e", "\n")
        expect(subject.send(:gets)).to eq("line")
      end

      it 'should catch escaped newlines' do
        expect(subject).to receive(:io).at_least(:once).and_return(mock_serial = double)
        expect(mock_serial).to receive(:read).exactly(7).times.with(1).and_return("l", "1", "\\", "\n", "l", "2", "\n")
        expect(subject.send(:gets)).to eq("l1\nl2")
      end

      it 'should return a blank string if there is just a newline' do
        expect(subject).to receive(:io).at_least(:once).and_return(mock_serial = double)
        expect(mock_serial).to receive(:read).exactly(1).times.with(1).and_return("\n")
        expect(subject.send(:gets)).to eq("")
      end

      it 'should allow escaped backslashes' do
        expect(subject).to receive(:io).at_least(:once).and_return(mock_serial = double)
        expect(mock_serial).to receive(:read).exactly(3).times.with(1).and_return("\\", "\\", "\n")
        expect(subject.send(:gets)).to eq("\\")
      end
    end
  end
end
