require 'socket'

module Dino
  module TxRx
    class TCP < Base
      def initialize(host, port=3466)
        @host, @port = host, port
      end

      def write(message)
        loop do
          if IO.select(nil, [io], nil)
            io.syswrite(message)
            break
          end
        end
      end
    
    private

      def connect
        Timeout::timeout(10) { TCPSocket.open(@host, @port) }
      rescue
        raise BoardNotFound
      end

      def gets(timeout=0.005)
        IO.select([io], nil, nil, timeout) && io.gets
      end
    end
  end
end
