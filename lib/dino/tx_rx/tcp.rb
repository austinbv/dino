require 'socket'
require 'observer'

module Dino
  module TxRx
    class TCP
      include Observable

      def initialize(host, port=80)
        @host, @port = host, port
      end

      def io
        @io ||= connect
      end

      def read
        @thread ||= Thread.new do
          loop do
            while line = io.gets
              pin, message = line.chomp.split(/::/)
              pin && message && changed && notify_observers(pin, message)
            end
            sleep 0.004
          end
        end
      end

      def close_read
        return nil if @thread.nil?
        Thread.kill(@thread)
        @thread = nil
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
