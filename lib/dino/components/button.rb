module Dino
  module Components
    class Button < Basic::DigitalInput
      alias :down :on_low
      alias :up   :on_high
      
      def perform_click
          update HIGH
          update LOW
      end
    end
  end
end
