module Dino
  module Components
    class Led < Basic::PWMOut
      def blink(interval=0.5)
        threaded_loop do 
          toggle
          sleep interval
        end
      end
    end
  end
end
