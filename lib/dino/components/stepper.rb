module Dino
  module Components
    class Stepper < BaseComponent

      def after_initialize(options={})
        raise 'missing pins[:step] pin' unless self.pins[:step]
        raise 'missing pins[:direction] pin' unless self.pins[:direction]

        set_pin_mode(pins[:step], :out)
        set_pin_mode(pins[:direction], :out)
        digital_write(pins[:step], Board::LOW)
      end

      def step_cc
        digital_write(self.pins[:direction], Board::HIGH)
        digital_write(self.pins[:step],      Board::HIGH)
        digital_write(self.pins[:step],      Board::LOW)
      end

      def step_cw
        digital_write(self.pins[:direction], Board::LOW)
        digital_write(self.pins[:step],      Board::HIGH)
        digital_write(self.pins[:step],      Board::LOW)
      end
    end
  end
end
