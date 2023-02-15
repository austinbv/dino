require 'observer'
require 'timeout'

module Dino
  module TxRx
    class SerialConnectError < StandardError; end
    class TCPConnectError    < StandardError; end
    class HandshakeError     < StandardError; end
    class RxFlushTimeout     < StandardError; end

    class Base
      include Observable
      include Handshake
      # We need the methods in FlowControl to wrap subclass methods too.
      def self.inherited(subclass)
        subclass.send(:prepend, FlowControl)
      end

    private

      def io
        @io ||= connect
      end

      def io_reset
        flush_read
        stop_read
        start_read
      end

      def flush_read
        Timeout.timeout(5) { read until read == nil }
      rescue Timeout::Error
        raise RxFlushTimeout, "Cannot read from device, or device not running dino"
      end

      def start_read
        @thread ||= Thread.new do
          trap("INT") do
            io.write("\n91\n")
            raise Interrupt
          end

          loop do
            read_and_parse
          end
        end
      end

      def stop_read
        Thread.kill(@thread) if @thread
        @thread = nil
      end

      def parse(line)
        changed && notify_observers(line)
      end
    end
  end
end
