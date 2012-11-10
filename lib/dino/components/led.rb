module Dino
  module Components
    class Led < BaseComponent
      def after_initialize(options={})
        set_pin_mode(:out)
        off
      end

      def on
        digital_write(Board::HIGH)
      end

      def off
        digital_write(Board::LOW)
      end
    end
  end
end
