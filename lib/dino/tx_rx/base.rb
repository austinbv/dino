require 'observer'
require 'timeout'

module Dino
  module TxRx
    class Base
      include Observable

      def read
        @thread ||= Thread.new do
          loop do
            line = gets
            if line && line.match(/\A\d+:/)
              pin, message = line.chop.split(/:/)
              pin && message && changed && notify_observers(pin, message)
            end
          end
        end
      end

      def close_read
        return nil if @thread.nil?
        Thread.kill(@thread)
        @thread = nil
      end

      def write(message)
        loop do
          if IO.select(nil, [io], nil)
            io.syswrite(message)
            break
          end
        end
      end

      def handshake
        flush_read
        100.times do
          begin
            write("!9000000.")
            Timeout::timeout(0.1) do
              line = gets.to_s
              if line.match /ACK:/
                flush_read
                return line.chop.split(/:/)[1].to_i
              end
            end
          rescue
            nil
          end
        end
       raise BoardNotFound
      end

      def flush_read
        gets until gets == nil
      end

      def gets
        IO.select([io], nil, nil, 0.005) && io.gets
      end
    end
  end
end