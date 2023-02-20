module Dino
  module Components
    module Setup
      module SinglePin
        include Base
        attr_reader :pin, :mode

        protected

        attr_writer :pin

        def initialize_pins(options={})
          if options[:pin]
            self.pin = options[:pin]
          else
            raise ArgumentError, 'a pin is required for this component'
          end
        end

        def mode=(mode)
          board.set_pin_mode(pin, mode)
          @mode = mode
        end
      end
    end
  end
end
