module Dino
  module AnalogIO
    class Input
      include Behaviors::InputPin
      include Behaviors::Reader
      include Behaviors::Poller
      include Behaviors::Listener
      
      def before_initialize(options={})        
        options[:board] = options[:adc] if options[:adc]
        options[:adc] = nil
        super(options)
      end

      def after_initialize(options={})
        super(options)

        # Default 16ms listener for analog inputs connected to a Board.
        @divider = 16

        # If using a negative input on a supported ADC, store the pin.
        @negative_pin = options[:negative_pin]

        # If the ADC has a programmable amplifier, pass through its setting.
        @gain = options[:gain]

        # If using a non-default sampling rate, store it.
        @sample_rate = options[:sample_rate]

        # Default to smoothing disabled.
        @smoothing        = false
        @smoothing_set  ||= []
      end

      attr_reader :negative_pin, :gain, :sample_rate

      # ADCs can set this based on gain, so exact voltages can be calculated.
      attr_accessor :volts_per_bit

      def _read
        board.analog_read(pin, negative_pin, gain, sample_rate)
      end

      def _listen(divider=nil)
        @divider = divider || @divider
        board.analog_listen(pin, @divider)
      end
      
      # Attach a callback that only fires when state changes.
      def on_change(&block)
        add_callback(:on_change) do |new_state|
          block.call(new_state) if new_state != self.state
        end
      end

      #
      # Smoothing features.
      # Does a moving average of the last 8 readings.
      #
      attr_accessor :smoothing

      def smooth_input(value)
        # Add new value, but limit to the 8 latest values.
        @smoothing_set << value
        @smoothing_set.shift if @smoothing_set.length > 8
        
        average = @smoothing_set.reduce(:+) / @smoothing_set.length.to_f
        
        # Round up or down based on previous state to reduce fluctuations.
        state && (state > average) ? average.ceil : average.floor
      end

      # Convert data to integer, or pass it through smoothing if enabled.
      def pre_callback_filter(value)
        smoothing ? smooth_input(value.to_i) : value.to_i
      end
    end
  end
end
