require 'socket'

module Dino
  module TxRx
    class TCP < Base
      def initialize(host, port=3466)
        @host, @port = host, port
      end

      def io
        @io ||= connect
      end

    private

      def connect
        Timeout::timeout(10) { TCPSocket.open(@host, @port) }
      rescue
        raise BoardNotFound
      end
    end
  end
end
