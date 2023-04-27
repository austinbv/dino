require_relative '../../test_helper'

class DummySerial
  def read
    ""
  end

  def write(message)
    nil
  end
end

class TCPConnectionTest < Minitest::Test
  # Force autoload.
  Dino::Connection::TCP

  def connection
    @connection ||= Dino::Connection::TCP.new("127.0.0.1", 3467)
  end

  def io
    suppress_output do
      connection.send(:io)
    end
  end

  def test_connect_raises_if_server_unavailable
    assert_raises(Dino::Connection::TCPConnectError) { io }
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
