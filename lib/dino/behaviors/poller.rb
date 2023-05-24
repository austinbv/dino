module Dino
  module Behaviors
    module Poller
      include Reader
      include Threaded
      
      def poll_using(method, interval, *args, &block)
        unless [Integer, Float].include? interval.class
          raise ArgumentError, "wrong interval given to #poll : #{interval.inspect}"
        end

        stop
        add_callback(:poll, &block) if block_given?

        threaded_loop do
          method.call(*args)
          sleep interval
        end
      end

      def poll(interval, *args, &block)
        poll_using(self.method(:_read), interval, *args, &block)
      end

      def stop
        super if defined?(super)
        stop_thread
        remove_callbacks :poll
      end
    end
  end
end
