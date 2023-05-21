module Dino
  module AnalogIO
    class Potentiometer < Input      
      def after_initialize(options={})
        super(options)
        
        # Enable smoothing.
        self.smoothing = true

        # Start listening immediately. Read 2x as often as regular Input.
        listen(@divider = 8)
      end
    end
  end
end
