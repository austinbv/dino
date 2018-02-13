module Dino
  module Components
    class RotaryEncoder
      include Setup::MultiPin
      include Mixins::Callbacks

      proxy_pins data: Basic::DigitalInput,
                 clock: Basic::DigitalInput

      attr_reader :position, :steps, :degrees_per_step
      alias :position :state

      def after_initialize(options={})
        super(options)

        # Default to listening every tick (1ms / 1kHz)
        divider = options[:divider] || 1
        clock.listen(divider)
        data.listen(divider)

        # Setup to track position in degrees.
        @steps = options[:steps] || 30
        @degrees_per_step = (360 / steps).to_f
        @state = 0.0

        start
      end

      def start
        clock.add_callback do |clock_state|
          (data.state == clock_state) ? self.update(-1) : self.update(1)
        end
      end

      #
      # Callbacks#update calls these before and after callbacks respectively.
      #
      # Take data (+/- 1 step change) and calculate new position (state) in degrees.
      # Leave old position in @state for now, so callbacks can compare to it.
      #
      # Return a hash with the new :position and pass through :change, overriding
      # the data param we took, which would have passed directly to callbacks.
      # Callbacks can use either :position (in degrees) or :change (in steps).
      #
      def pre_callback_filter(data)
        { change: data, position: (state + (data * degrees_per_step)) % 360 }
      end
      #
      # Callbacks run now, receiving only the value of #pre_callback_filter
      #
      # After callbacks, set @state to the position calculated earlier.
      # This method also receives the result of #pre_callback_filter.
      #
      def update_self(data)
        @state = data[:position]
      end

      def reset_position
        @callbacks_mutex.synchronize { @state = 0 }
      end
    end
  end
end
