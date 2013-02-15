require 'observer'

module Dino
  module TxRx
    class Base
      include Observable

      def read
        @thread ||= Thread.new do
          loop do
            line = gets
            if line
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
            io.write(message)
            break
          end
        end
      end

      def flush_read
        gets until gets == nil
      end

      def gets
        IO.select([io], nil, nil, 0.01) && io.gets
      end
    end
  end
end