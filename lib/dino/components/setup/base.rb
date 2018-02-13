module Dino
  module Components
    module Setup
      module Base
        attr_reader :board, :state

        def initialize(options={})
          initialize_board(options)
          initialize_pins(options)
          register
          after_initialize(options)
        end

        protected

        attr_writer :board, :state

        def initialize_board(options={})
          raise 'a board is required for a component' unless options[:board]
          self.board = options[:board]
        end

        def register
          board.add_component(self)
        end

        def unregister
          board.remove_component(self)
        end

        #
        # Setup::Base only requires a board. Mix in modules from Setup or define
        # this method in your class to use pins.
        #
        def initialize_pins(options={}) ; end
        alias :initialize_pin :initialize_pins

        # Override in components. Call super when inheriting or mixing in.
        def after_initialize(options={}); end
      end
    end
  end
end
