module Dino
  module Components
    module Mixins
      module Poller
        include Reader
        include Threaded

        def poll_using(method, interval=1, &block)
          stop
          add_callback(:poll, &block) if block_given?

          threaded_loop do
            method.call
            sleep interval
          end
        end

        def poll(interval=1, &block)
          poll_using(method(:_read), interval, &block)
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
