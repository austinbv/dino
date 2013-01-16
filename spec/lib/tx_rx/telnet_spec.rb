require 'spec_helper'

module Dino
  describe TxRx::Telnet do

    before :each do
      @mock_telnet = mock
      Net::Telnet.stub(:new) { @mock_telnet }
      @instance = TxRx::Telnet.new("127.0.0.1", 3001)
    end 

    describe '#connect' do
      it 'should raise a BoardNotFound exception if it cannot connect to the server' do
        Net::Telnet.stub(:new).and_raise
        @instance = TxRx::Telnet.new("0.0.0.0", 999999)
        expect { @instance.io }.to raise_exception BoardNotFound
      end
    end

    describe '#io' do
      it 'should set io to a new telnet connection with the specified host and port' do
        Net::Telnet.should_receive(:new).with("Host" => "127.0.0.1", "Port" => 3001)
        @instance.io
      end

      it 'should use the existing io instance if set' do
        Net::Telnet.should_receive(:new).exactly(1).times.with("Host" => "127.0.0.1", "Port" => 3001)
        2.times { @instance.io }
      end
    end

    describe '#read' do
      it 'should create a new thread' do
        Thread.should_receive :new
        @instance.read
      end

      it 'should get messages from the device' do
        Thread.should_receive(:new).and_yield
        @instance.should_receive(:loop).and_yield
        @instance.io.should_receive(:waitfor).with("\n").and_yield("foo::bar\n")
        @instance.should_receive(:changed).and_return(true)
        @instance.should_receive(:notify_observers).with('foo','bar')

        @instance.read
      end
    end

    describe '#close_read' do
      it 'should kill the reading thread' do
        @instance.instance_variable_set(:@thread, mock_thread = mock)
        Thread.should_receive(:kill).with(mock_thread)
        @instance.read
        @instance.close_read
      end
    end

    describe '#write' do
      it 'should write to the device' do
        @mock_telnet.should_receive(:puts).with("foo::bar")
        @instance.write("foo::bar")
      end
    end

  end
end
