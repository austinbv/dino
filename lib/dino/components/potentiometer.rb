module Dino
  module Components
    class Potentiometer < Basic::AnalogInput
      
      attr_accessor :smoothing
      
      def after_initialize(options={})
        super(options)
        
        # Read 2x as often than regular AnalogInput.
        @divider = 8
        
        # Keep values to smooth with moving average by default.
        self.smoothing = true
        @moving_set = []
        
        # Start listening immediately.
        listen
      end
      
      def smoothing_on
        self.smoothing = true
      end
      
      def smoothing_off
        self.smoothing = false
      end
      
      def on_change(&block)
        add_callback(:on_change) do |new_state|
          block.call(new_state) if new_state != self.state
        end
      end
      
      def pre_callback_filter(value)
        smoothing ? smooth_input(value) : value
      end
      
      def smooth_input(value)
        # Add new value, but limit to the 8 latest values.
        @moving_set << value.to_i
        @moving_set.shift if @moving_set.length > 8
        
        average = @moving_set.reduce(:+) / @moving_set.length.to_f
        
        # Round up or down based on previous state to smooth even more.
        state && (state > average) ? average.ceil : average.floor
      end
    end
  end
end
