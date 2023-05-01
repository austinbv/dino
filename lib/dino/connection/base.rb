require 'observer'
require 'timeout'

module Dino
  module Connection
    class SerialConnectError < StandardError; end
    class RxFlushTimeout     < StandardError; end

    class Base
      include Observable
      include Handshake
      # We need the methods in FlowControl to wrap subclass methods too.
      def self.inherited(subclass)
        subclass.send(:prepend, FlowControl)
      end

      def stop
        stop_read
        stop_write
      end

    private
    
      def parse(line)
        return unless line

        if line.match(/\ADBG:/)
          puts line.inspect
        else
          changed && notify_observers(line)
        end
      end

      def io
        @io ||= connect
      end

      def io_reset
        flush_read
        stop_read
        start_read
        stop_write
        start_write
      end

      def flush_read
        Timeout.timeout(5) { _read until _read == nil }
      rescue Timeout::Error
        raise RxFlushTimeout, "Cannot read from device, or device not running dino"
      end

      def start_read
        @read_thread ||= Thread.new do
          loop { parse(read) }
        end
      end

      def stop_read
        Thread.kill(@read_thread) if @read_thread
        @read_thread = nil
      end
      
      def start_write
        @write_thread ||= Thread.new do
          # Tell the board to reset if our script is interrupted.
          trap("INT") do
            _write "\n91\n"
            raise Interrupt
          end
          
          loop { write_from_buffer }
        end
      end
      
      def stop_write
        Thread.kill(@write_thread) if @write_thread
        @write_thread = nil
      end
    end
  end
end
