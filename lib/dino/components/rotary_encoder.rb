module Dino
  module Components
    class RotaryEncoder
      include Setup::MultiPin
      include Mixins::Callbacks

      proxy_pins data: Basic::DigitalInput,
                 clock: Basic::DigitalInput

      def after_initialize(options={})
        super(options) if defined?(super)
        @state = 0

        # Stop the default behavior of the DigitalInput instances.
        clock.stop; data.stop;
        clock.listen(1); data.listen(1)
        sleep 0.5

        start
      end

      def start
        proxies[:clock].add_callback do |clock_state|
          (data.state == clock_state) ? self.update(@state + 1) : self.update(@state - 1)
        end
      end
    end
  end
end
