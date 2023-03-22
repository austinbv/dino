module Dino
  module Components
    class L298
      include Setup::MultiPin
      
      def initialize_pins(options={})        
        proxy_pin :in1,    Basic::DigitalOutput
        proxy_pin :in2,    Basic::DigitalOutput
        proxy_pin :enable, Basic::DACOut 
      end
                  
      def after_initialize(options={})
        in1.low
        in2.low
        enable.low
      end

      def speed=(speed)
        enable.write(speed)
      end
      
      def forward(speed=0)
        in1.high
        in2.low
        self.speed = speed
      end
      
      def reverse(speed=0)
        in1.low
        in2.high
        self.speed = speed
      end
      
      def idle
        in1.low
        in2.low
        self.speed = 0
      end
      alias :off :idle
      
      def brake
        in1.high
        in2.high
        self.speed = board.pwm_high
      end
    end
  end
end
