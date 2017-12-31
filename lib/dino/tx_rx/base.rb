require 'observer'
require 'timeout'

module Dino
  module TxRx
    class BoardNotFound < StandardError; end

    class Base
      include Observable
      BOARD_BUFFER = 60

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
        10.times do |retries|
          begin
            Timeout.timeout(1) do
              write Dino::Message.encode(command: 90)
              loop do
                line = gets
                if line && line.match(/ACK:/)
                  flush_read
                  ignore_retry_bytes(retries)
                  puts "Connected to board..."
                  return line.split(/:/)[1]
                end
              end
            end
          rescue Timeout::Error
            puts "Could not find board. Retrying..."
          end
        end
        raise BoardNotFound
      end

    private

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

      def io_write(message); raise "#io_write should be defined in TxRx subclasses"; end

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

      # Subtract bytes for failed handshakes from the total in transit bytes.
      # The board will never acknowledge these.
      def ignore_retry_bytes(retries)
        retry_bytes = Dino::Message.encode(command: 90).length * retries
        remove_transit_bytes(retry_bytes)
      end

      def connect(message); raise "#connect should be defined in TxRx subclasses"; end
      def gets(message); raise "#gets should be defined in TxRx subclasses"; end

      def flush_read
        gets until gets == nil
      end
    end
  end
end
