require 'socket'

module Dino
  module TxRx
    class TCP < Base
      def initialize(host="127.0.0.1", port=3466)
        @host = host
        @port = port
      end

      def to_s
        "#{@host}:#{@port}"
      end

    private

      def connect
        print "Connecting to TCP at: #{self.to_s}... "
        connection = Timeout::timeout(10) do
          TCPSocket.open(@host, @port)
        end
        puts "Connected"
        connection
      rescue => error
        raise TCPConnectError, error.message
      end

      def _write(message)
        loop do
          if IO.select(nil, [io], nil, 0)
            io.syswrite(message)
            break
          end
        end
      end

      def _read
        IO.select([io], nil, nil, 0) && io.gets.gsub(/\n\z/, "")
      end
    end
  end
end
