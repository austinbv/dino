module Dino
  module Behaviors
    module SinglePin
      include Component
      attr_reader :pin, :mode
      
      def mode=(mode)          
        board.set_pin_mode(pin, mode)
        @mode = mode
      end
      
    protected

      attr_writer :pin

      def initialize_pins(options={})
        raise ArgumentError, 'a pin is required for this component' unless options[:pin]
        self.pin = options[:pin]
      end
    end
  end
end
