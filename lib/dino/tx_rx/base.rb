require 'observer'
require 'timeout'

module Dino
  module TxRx
    class BoardNotFound < StandardError; end

    class Base
      include Observable

      def io
        @io ||= connect
      end

      def _read
        line = gets
        if line && line.match(/\A\d+:/)
          pin, message = line.chop.split(/:/)
          pin && message && changed && notify_observers(pin, message)
        else
          sleep 0.005
        end
      end

      def read
        @thread ||= Thread.new { loop { _read } }.abort_on_exception = true
      end

      def close_read
        return nil if @thread.nil?
        Thread.kill(@thread)
        @thread = nil
      end

      def handshake
        flush_read
        10.times do
          begin
            Timeout.timeout(1) do
              write Dino::Message.encode(command: 90)
              loop do
                line = gets
                if line && line.match(/ACK:/)
                  puts "Connected to board..."
                  flush_read
                  return line.chop.split(/:/)[1]
                end
              end
            end
          rescue Timeout::Error
            puts "Could not find board. Retrying..."
          end
        end
        raise BoardNotFound
      end

      def write(message); raise "#write should be defined in TxRx subclasses"; end

    private

      def connect(message); raise "#connect should be defined in TxRx subclasses"; end
      def gets(message); raise "#gets should be defined in TxRx subclasses"; end

      def flush_read
        gets until gets == nil
      end
    end
  end
end
