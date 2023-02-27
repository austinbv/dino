module Dino
  module Components
    module Setup
      module Base
        attr_reader :board

        def initialize(options={})
          @state = nil
          @state_mutex = Mutex.new
          before_initialize(options)
          initialize_board(options)
          initialize_pins(options)
          register
          after_initialize(options)
        end
        
        def state
          @state_mutex.synchronize { @state }
        end

        protected

        def state=(value)
          @state_mutex.synchronize { @state = value }
        end

        def initialize_board(options={})
          if options[:board]
            @board = options[:board]
          else
            raise ArgumentError, 'a board is required for a component'
          end
        end

        def register
          board.add_component(self)
        end

        def unregister
          board.remove_component(self)
        end

        # Setup::Base only requires a board.
        # Include modules from Setup or override this to use pins.
        #
        def before_initialize(options={}) ; end
        def initialize_pins(options={}) ; end
        alias :initialize_pin :initialize_pins

        # Override in components. Call super when inheriting or mixing in.
        def after_initialize(options={}); end
      end
    end
  end
end
