module Dino
  module Components
    module Core
      class Base
        attr_reader :board, :pin, :mode, :pullup, :state

        def initialize(options={})
          raise 'board and pin are required for a component' if options[:board].nil? || options[:pin].nil?

          self.board = options[:board]
          self.pin = board.convert_pin(options[:pin])
          @pullup = options[:pullup]

          after_initialize(options)
        end

        protected

        attr_writer :board, :pin

        #
        # Components::Core::Base does a lot of setup work for you.
        # Define #after_initialize in your subclass instead of overriding #initialize
        #
        # @note This method should be implemented in the BaseComponent subclass.
        #
        def after_initialize(options={}) ; end

        def mode=(mode)
          @mode = mode
          board.set_pin_mode(self.pin, mode, pullup)
        end

        def pullup=(pullup)
          @pullup = pullup
          board.set_pullup(self.pin, pullup)
        end
      end
    end
  end
end
