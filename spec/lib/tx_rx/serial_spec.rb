require 'spec_helper'

module Smalrubot
  describe TxRx::Serial do
    it { should be }

    describe '#initialize' do
      it 'should set first_write to true' do
        TxRx::Serial.new.instance_variable_get(:@first_write).should == true
      end

      it 'should set the device and buad if specified' do
        txrx = TxRx::Serial.new({device: "/dev/ttyACM0", baud: 9600})
        txrx.instance_variable_get(:@baud).should == 9600
        txrx.instance_variable_get(:@device).should == "/dev/ttyACM0"
      end
    end

    describe '#io' do
      context "on windows" do
        it 'should instantiate a new ::Serial for the first available tty device' do
          original_platform = RUBY_PLATFORM
          Constants.redefine(:RUBY_PLATFORM, "mswin", :on => Object)
          subject.instance_variable_set('@tty_devices', ["COM1", "COM2", "COM3"])

          # COM2 is chosen as available for this test.
          ::Serial.should_receive(:new).with("COM1", TxRx::Serial::BAUD).and_raise
          ::Serial.should_receive(:new).with("COM2", TxRx::Serial::BAUD).and_return(mock_serial = double)
          ::Serial.should_not_receive(:new).with("COM3", TxRx::Serial::BAUD)

          subject.io.should == mock_serial
          Constants.redefine(:RUBY_PLATFORM, original_platform, :on => Object)
        end
      end

      context "on unix" do
        it 'should instantiate a new ::Serial for the first available tty device' do
          subject.should_receive(:tty_devices).and_return(['/dev/ttyACM0', '/dev/tty.usbmodem1'])

          # /dev/ttyACM0 is chosen as available for this test.
          ::Serial.should_receive(:new).with('/dev/ttyACM0', TxRx::Serial::BAUD).and_return(mock_serial = double)
          ::Serial.should_not_receive(:new).with('/dev/tty.usbmodem1', TxRx::Serial::BAUD)

          subject.io.should == mock_serial
        end
      end

      it 'should connect to the specified device at the specified baud rate' do
        subject.should_receive(:tty_devices).and_return(["/dev/ttyACM0"])
        ::Serial.should_receive(:new).with('/dev/ttyACM0', 9600).and_return(mock_serial = double)

        subject.instance_variable_set(:@device, "/dev/ttyACM0")
        subject.instance_variable_set(:@baud, 9600)

        subject.io.should == mock_serial
      end

      it 'should use the existing io instance if set' do
        subject.should_receive(:tty_devices).once.and_return(['/dev/tty.ACM0', '/dev/tty.usbmodem1'])
        ::Serial.stub(:new).and_return(mock_serial = double)

        3.times { subject.io }
        subject.io.should == mock_serial
      end

      it 'should raise a BoardNotFound exception if there is no board connected' do
        ::Serial.stub(:new).and_raise
        expect { subject.io }.to raise_exception BoardNotFound
      end
    end

    describe '#write' do
      it 'should write to the device' do
        subject.stub(:io).and_return(mock_serial = double)
        msg = 'a message'
        mock_serial.should_receive(:write).with(msg).and_return(msg.length)
        subject.write('a message')
      end
    end
  end
end
