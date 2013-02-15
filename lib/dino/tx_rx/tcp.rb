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

    private

      def connect
        TCPSocket.open(@host, @port)
      rescue
        raise BoardNotFound
      end
    end
  end
end
