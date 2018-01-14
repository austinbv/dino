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
      # Let the methods in FlowControl wrap subclass methods too.
      def self.inherited(subclass)
        subclass.prepend FlowControl
      end
      include Handshake

      def read(message);  raise "#read should be defined in TxRx subclasses";  end
      def write(message); raise "#write should be defined in TxRx subclasses"; end

    private

      def io
        @io ||= connect
      end

      def io_reset
        flush_read; stop_read; start_read
      end

      def connect(message); raise "#connect should be defined in TxRx subclasses"; end

      def flush_read
        Timeout.timeout(5) { read until read == nil }
        rescue Timeout::Error
        raise RxFlushTimeout "Cannot read from device, or device not running dino"
      end

      def start_read
        @thread ||= Thread.new { loop { read_and_process } }.abort_on_exception = true
      end

      def stop_read
        return nil if @thread.nil?
        Thread.kill(@thread)
        @thread = nil
      end

      def read_and_process(message); raise "#read_and_process should be defined in FlowControl module"; end

      def process(line)
        if line.match(/\A\d+:/)
          pin, message = line.split(":", 2)
          pin && message && changed && notify_observers(pin, message)
        end
      end
    end
  end
end
