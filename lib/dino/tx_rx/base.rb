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
      BOARD_BUFFER = 60
      HANDSHAKE_TRIES = 3
      HANDSHAKE_TIMEOUT = 2

      def io
        @io ||= connect
      end

      def read
        @thread ||= Thread.new { loop { _read } }.abort_on_exception = true
      end

      def close_read
        return nil if @thread.nil?
        Thread.kill(@thread)
        @thread = nil
      end

      def write(message)
        @write_mutex.synchronize { synced_write(message) }
      end

      def handshake
        initialize_flow_control
        flush_read
        HANDSHAKE_TRIES.times do |retries|
          begin
            Timeout.timeout(HANDSHAKE_TIMEOUT) do
              print "Sending handshake to: #{self.to_s}... "
              write Dino::Message.encode(command: 90)
              loop do
                line = gets
                if line && line.match(/\AACK:/)
                  flush_read
                  ignore_retry_bytes(retries)
                  puts "Acknowledged. Hardware ready...\n\n"
                  return line.split(":", 2)[1]
                end
              end
            end
          rescue Timeout::Error
            print "No response, "
            puts (retries + 1 < HANDSHAKE_TRIES ? "retrying..." : "exiting...")
            next
          end
        end
        raise HandshakeError, "Connected to wrong device, or device not running dino"
      end

    private

      def flush_read
        Timeout.timeout(5) do
          gets until gets == nil
        end
      rescue Timeout::Error
        raise RxFlushTimeout "Cannot read from device, or device not running dino"
      end

      def synced_write(message)
        message = message.split("")
        loop do
          @flow_control.synchronize do
            bytes = BOARD_BUFFER - @transit_bytes
            break unless bytes > 0

            bytes = message.length if (message.length < bytes)
            fragment = String.new
            bytes.times { fragment << message.shift }
            io.write(fragment)
            @transit_bytes = @transit_bytes + bytes
          end
          return if message.empty?
          sleep 0.005
        end
      end

      def connect(message); raise "#connect should be defined in TxRx subclasses"; end
      def gets(message);    raise "#gets should be defined in TxRx subclasses";    end
      def _write(message);  raise "#_write should be defined in TxRx subclasses";  end

      def _read
        line = gets
        line ? process_line(line) : sleep(0.005)
      end

      def process_line(line)
        if line.match(/\A\d+:/)
          pin, message = line.split(":", 2)
          pin && message && changed && notify_observers(pin, message)
        elsif line.match(/\ARCV:/)
          # This is acknowledgement from the board that bytes have been read
          # out of the hardware buffer, freeing up that space.
          # Subtract from the transit bytes so #synced_write can send more data.
          remove_transit_bytes(line.split(/:/)[1].to_i)
        end
      end

      # Subtract bytes for failed handshakes from the total in transit bytes.
      # The board likely reset, dropping these bytes, and causing the retries.
      def ignore_retry_bytes(retries)
        retry_bytes = Dino::Message.encode(command: 90).length * retries
        remove_transit_bytes(retry_bytes)
      end

      def initialize_flow_control
        @flow_control  ||= Mutex.new
        @write_mutex   ||= Mutex.new
        @transit_bytes ||= 0
      end

      def transit_bytes
        @flow_control.synchronize { @transit_bytes }
      end

      def add_transit_bytes(value)
        @flow_control.synchronize { @transit_bytes = @transit_bytes + value }
      end

      def remove_transit_bytes(value)
        @flow_control.synchronize { @transit_bytes = @transit_bytes - value }
      end
    end
  end
end
