module Dino
  module Components
    module Setup
      module SinglePin
        include Base
        attr_reader :pin, :mode

        protected

        attr_writer :pin

        #
        # Require a single pin for single pin components.
        #
        def initialize_pins(options={})
          raise 'a pin is required for this component' unless options[:pin]
          self.pin = board.convert_pin(options[:pin])
        end

        def mode=(mode)
          @mode = mode
          board.set_pin_mode(self.pin, mode)
        end
      end
    end
  end
end
