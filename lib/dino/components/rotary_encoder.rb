module Dino
  module Components
    class RotaryEncoder
      include Setup::MultiPin
      include Mixins::Callbacks

      proxy_pins clock: Basic::DigitalInput,
                 data: Basic::DigitalInput
                 
      attr_accessor :degrees_per_step
      
      def after_initialize(options={})
        super(options)
                
        if options[:steps_per_revolution] 
          self.degrees_per_step = (360 / options[:steps_per_revolution])
        else
          self.degrees_per_step = 12
        end
        reset
        
        # DigitalInputs listen with default divider automatically. Override here.
        divider = options[:divider] || 1
        clock.listen(divider)
        data.listen(divider)

        observe_pins
      end
      
      def angle
        state[:angle]
      end

      def steps
        state[:steps]
      end
      
      def reset
        self.state = {steps: 0, angle: 0}
      end
      
      private

      def observe_pins
        #
        # This is a quirk of how listeners work.
        # When observing the pins, attach a callback to the higher numbered pin,
        # then read state from the lower. If not, direction will be reversed.
        #
        if board.convert_pin(clock.pin) > board.convert_pin(data.pin)
          trailing = clock
          leading = data
        else
          trailing = data
          leading = clock
        end
        
        trailing.add_callback do |trailing_state|
          (leading.state == trailing_state) ? self.update(1) : self.update(-1)
        end
      end
      
      #
      # Take data (+/- 1 step change) and calculate new state.
      # Return a hash with the new :steps and :angle. Pass through raw
      # value in :change, so callbacks can use any of these.
      #
      def pre_callback_filter(step)
        # Copy old state through the mutex wrapped reader.
        temp_state = state.dup
        temp_state[:change] = step
        temp_state[:steps]  = temp_state[:steps]  + step
        temp_state[:angle]  = (temp_state[:angle] + (step * degrees_per_step)) % 360
        temp_state
      end

      #
      # After callbacks, set state to the hash from before, except change.
      #
      def update_state(new_state)
        self.state = new_state.except(:change)
      end
    end
  end
end
