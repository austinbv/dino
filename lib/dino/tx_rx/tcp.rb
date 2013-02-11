require 'socket'

module Dino
  module TxRx
    class TCP < Base
      def initialize(host, port=80)
        @host, @port = host, port
      end

      def io
        @io ||= connect
      end

      def gets
        io.gets
      end

      def flush_read
        loop do; Timeout::timeout(0.005) { gets } end
      rescue
        nil
      end

      def write(message)
        io.write(message + "\r\n")
      end

    private

      def connect
        TCPSocket.open(@host, @port)
      rescue
        raise BoardNotFound
      end
    end
  end
end
