require 'observer'

module Dino
  module TxRx
    class Base
      include Observable

      def read
        @thread ||= Thread.new do
          loop do
            pin, message = gets.chop.split(/:/) 
            pin && message && changed && notify_observers(pin, message)
          end
        end
      end

      def flush_read
      end

      def close_read
        return nil if @thread.nil?
        Thread.kill(@thread)
        @thread = nil
      end
      
    end
  end
end