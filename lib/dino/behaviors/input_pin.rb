module Dino
  module Behaviors
    module InputPin
      include SinglePin
      
      def _stop_listener
        board.stop_listener(pin)
      end

    protected
    
      def initialize_pins(options={})
        super(options)
        
        initial_mode = :input
        initial_mode = :input_pullup   if options[:pullup]
        initial_mode = :input_pulldown if options[:pulldown]
        initial_mode = options[:mode]  if options[:mode]
        
        self.mode = initial_mode
      end
    end
  end
end
