require 'spec_helper'

module Dino
  describe TxRx::TCP do
    before :each do
      @host = "127.0.0.1"
      @port = 3467
      @instance = TxRx::TCP.new(@host, @port)
    end

    describe "#connect" do
      it 'should raise a TCPConnectError exception if it cannot connect to the server' do
        expect { @instance.io }.to raise_exception Dino::TxRx::TCPConnectError
      end

      it 'should return the TCPSocket if connected' do
        @server = TCPServer.new @port
        expect(@instance.io).to be_a(TCPSocket)
        @server.close
      end
    end

    describe '#io' do
      it 'should set io to a new TCPSocket with the specified host and port' do
        expect(TCPSocket).to receive(:open).with(@host, @port)
        @instance.io
      end

      it 'should use the existing io instance if set' do
        @server = TCPServer.new @port
        socket = @instance.io
        expect(@instance.io).to equal(socket)
        @server.close
      end
    end
  end
end
