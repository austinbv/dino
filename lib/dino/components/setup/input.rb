module Dino
  module Components
    module Setup
      module Input
        include SinglePin
        
        def _stop_listener
          board.stop_listener(pin)
        end

      protected
      
        def initialize_pins(options={})
          super(options)
          if options[:pullup]
            self.mode = :input_pullup
          elsif options[:pulldown]
            self.mode = :input_pulldown
          else
            self.mode = :input
          end
        end
      end
    end
  end
end
