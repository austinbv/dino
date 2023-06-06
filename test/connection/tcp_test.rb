require_relative '../test_helper'

class TCPConnectionTest < Minitest::Test
  # Force autoload.
  Dino::Connection::TCP

  def test_connect_raises_if_server_unavailable
    assert_raises(Dino::Connection::TCPConnectError) do
      suppress_output do
        io = Dino::Connection::TCP.new("127.0.0.1", 3466).send(:io)
      end
    end
  end

  def test_connect
    server = TCPServer.new("127.0.0.1", 3467)
    io = nil
    suppress_output do
      io = Dino::Connection::TCP.new("127.0.0.1", 3467).send(:io)
    end
    assert_equal TCPSocket, io.class
    server.close
  end

  def test_io_doesnt_reconnect
    server = TCPServer.new("127.0.0.1", 3468)
    connection = nil
    io = nil
    suppress_output do
      connection = Dino::Connection::TCP.new("127.0.0.1", 3468)
      io = connection.send(:io)
    end
    socket = io
    assert_equal socket, connection.send(:io)
    server.close
  end
end
