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
      # Let the methods in FlowControl wrap subclass methods too.
      def self.inherited(subclass)
        subclass.send(:prepend, FlowControl)
      end

      def read(message)
        raise NotImplementedError
          .new("#{self.class.name}#read not defined in Dino::TxRx subclass")
      end

      def write(message)
        raise NotImplementedError
          .new("#{self.class.name}#write not defined in Dino::TxRx subclass")
      end

    private

      def io
        @io ||= connect
      end

      def connect
        raise NotImplementedError
          .new("#{self.class.name}#connect not defined in Dino::TxRx subclass")
      end

      def io_reset
        flush_read
        stop_read
        start_read
      end

      def flush_read
        Timeout.timeout(5) { read until read == nil }
        rescue Timeout::Error
        raise RxFlushTimeout "Cannot read from device, or device not running dino"
      end

      def start_read
        @thread ||= Thread.new { loop { read_and_parse } }
      end

      def stop_read
        return nil if @thread.nil?
        Thread.kill(@thread)
        @thread = nil
      end

      def read_and_parse
        raise NotImplementedError
          .new("#{self.class.name}#read_and_parse not defined in Dino::TxRx::FlowControl")
      end

      def parse(line)
        if line.match(/\A\d+:/)
          pin, message = line.split(":", 2)
          pin && message && changed && notify_observers(pin, message)
        end
      end
    end
  end
end
