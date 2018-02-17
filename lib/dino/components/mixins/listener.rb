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
          _stop_listener
          remove_callbacks :listen
        end
      end
    end
  end
end
