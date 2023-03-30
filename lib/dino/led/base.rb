module Dino
  module LED
    class Base < PulseIO::PWMOutput
      def blink(interval=0.5)
        threaded_loop do 
          toggle
          sleep interval
        end
      end
    end
  end
end
