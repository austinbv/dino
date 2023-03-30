module Dino
  module AnalogIO
    class Input
      include Behaviors::InputPin
      include Behaviors::Reader
      include Behaviors::Poller
      include Behaviors::Listener
      
      def after_initialize(options={})
        super(options)
        @divider = 16
      end

      def _read
        board.analog_read(pin)
      end

      def _listen(divider=nil)
        @divider = divider || @divider
        board.analog_listen(pin, @divider)
      end
      
      def pre_callback_filter(value)
        value.to_i
      end
    end
  end
end
