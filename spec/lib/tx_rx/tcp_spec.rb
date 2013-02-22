require 'spec_helper'

module Dino
  describe TxRx::TCP do
    before :each do
      @host = "127.0.0.1"
      @port = 3466
      @instance = TxRx::TCP.new(@host, @port)
    end

    describe "#connect" do
      it 'should raise a BoardNotFound exception if it cannot connect to the server' do
        expect { @instance.io }.to raise_exception BoardNotFound
      end

      it 'should return the TCPSocket if connected' do
        @server = TCPServer.new 3466
        @instance.io.should be_a TCPSocket
        @server.close
      end
    end

    describe '#io' do
      it 'should set io to a new TCPSocket with the specified host and port' do
        TCPSocket.should_receive(:open).with(@host, @port)
        @instance.io
      end

      it 'should use the existing io instance if set' do
        @server = TCPServer.new 3466
        socket = @instance.io
        @instance.io.should be socket
        @server.close
      end
    end
  end
end
