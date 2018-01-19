module Dino
  module Components
    module Mixins
      module Listener
      	include Callbacks

        def listen(divider=nil, &block)
          stop
          add_callback(:listen, &block) if block_given?
          _listen(divider)
        end

        def stop
          super if defined?(super)
          _stop_listen
          remove_callbacks :listen
        end

        def _listen
          raise NotImplementedError
            .new("#{self.class.name}#_listen is not defined.")
        end

        def _stop_listen
          raise NotImplementedError
            .new("#{self.class.name}#_stop_listen is not defined.")
        end
      end
    end
  end
end
