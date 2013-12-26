module Dino
  module Components
    class Stepper
      include Setup::MultiPin 
      
      proxy_pins  step:      Basic::DigitalOutput,
                  direction: Basic::DigitalOutput
    
      def step_cc
        direction.high
        step.high
        step.low
      end

      def step_cw
        direction.low
        step.high
        step.low
      end
    end
  end
end
