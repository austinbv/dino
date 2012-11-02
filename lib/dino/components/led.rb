module Dino
  module Components
    class Led < BaseComponent
      def initialize(options={})
        super(options)

        set_pin_mode(:out)
        digital_write(Board::LOW)
      end

      def on
        digital_write(Board::HIGH)
      end

      def off
        digital_write(Board::LOW)
      end

      def set(value)
        analog_write(value)
      end
    end
  end
end
