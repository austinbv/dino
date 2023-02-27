module Dino
  module Components
    module Mixins
      module Poller
        include Reader
        include Threaded
        
        def poll_using(method, interval=3, *args, &block)
          stop
          add_callback(:poll, &block) if block_given?

          threaded_loop do
            method.call(*args)
            sleep interval
          end
        end

        def poll(interval=3, *args, &block)
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
end
