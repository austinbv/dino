module Dino
  module Motor
    class L298
      include Behaviors::MultiPin
      
      def initialize_pins(options={})        
        proxy_pin :in1,    DigitalIO::Output
        proxy_pin :in2,    DigitalIO::Output
        proxy_pin :enable, PulseIO::PWMOutput 
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
