module Dino
  module Components
    module Mixins
      module Poller
        include Reader
        include Threaded

        def poll(interval=1, *args, &block)
          stop
          add_callback(:poll, &block) if block_given?
          threaded_loop do
            _read(*args); sleep interval
          end
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
