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
      
      def pre_callback_filter(value)
        value.to_i
      end
    end
  end
end
