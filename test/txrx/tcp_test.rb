require 'dino'
require 'minitest/autorun'
require 'txrx_mock'
require 'test_helper'

class DummySerial
  def read
    ""
  end

  def write(message)
    nil
  end
end

class TxRxTCPTest < Minitest::Test
  def txrx
    @txrx ||= Dino::TxRx::TCP.new("127.0.0.1", 3467)
  end

  def io
    suppress_output do
      txrx.send(:io)
    end
  end

  def test_connect_raises_if_server_unavailable
    assert_raises(Dino::TxRx::TCPConnectError) { io }
  end

  def test_connect
    server = TCPServer.new 3467
    assert_equal TCPSocket, io.class
    server.close
  end

  def test_io_doesnt_reconnect
    server = TCPServer.new 3467
    socket = io
    assert_equal socket, io
    server.close
  end
end
