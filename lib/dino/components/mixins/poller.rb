module Dino
  module Components
    module Mixins
      module Poller
        include Reader
        #
        # Make sure Threaded is in the including class.
        #
        def self.included(base)
          base.class_eval { include Threaded }
        end

        def poll(interval, &block)
          stop
          add_callback(:poll, &block) if block_given?
          threaded_loop do
            _read; sleep interval
          end
        end

        def stop
          super if defined?(super)
          stop_thread
          remove_callback :poll
        end
      end
    end
  end
end
