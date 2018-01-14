require 'socket'

module Dino
  module TxRx
    class TCP < Base
      def initialize(host, port=3466)
        @host, @port = host, port
      end

      def to_s
        "#{@host}:#{@port}"
      end

    private

      def connect
        print "Connecting to TCP at: #{self.to_s}... "
        connection = Timeout::timeout(10) { TCPSocket.open @host, @port }
        puts "Connected"
        connection
      rescue => error
        raise TCPConnectError, error.message
      end

      def write(message)
        loop do
          if IO.select(nil, [io], nil, 0)
            io.syswrite(message)
            break
          end
        end
      end

      def read
        IO.select([io], nil, nil, 0) && io.gets.gsub(/\n\z/, "")
      end
    end
  end
end
