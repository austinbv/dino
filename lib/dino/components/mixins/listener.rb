module Dino
  module Components
    module Mixins
      module Listener
      	include Callbacks

        def listen(&block)
          stop
          add_callback(:listen, &block) if block_given?
          _listen
        end

        def stop
          super if defined?(super)
          board.stop_listener(pin)
          remove_callbacks :listen
        end

        #
        # Including component should define this to start a listener on the board.
        #
        def _listen; end
      end
    end
  end
end
