module Dino
  module Components
    class Stepper < BaseComponent

      def initialize(options={})
        super(options)

        raise 'missing pins[:step] pin' unless self.pins[:step]
        raise 'missing pins[:direction] pin' unless self.pins[:direction]

        set_pin_mode(:out, pins[:step])
        set_pin_mode(:out, pins[:direction])
        digital_write(Board::LOW, pins[:step])
      end

      def step_cc
        digital_write(Board::HIGH, self.pins[:direction])
        digital_write(Board::HIGH, self.pins[:step])
        digital_write(Board::LOW, self.pins[:step])
      end

      def step_cw
        digital_write(Board::LOW, self.pins[:direction])
        digital_write(Board::HIGH, self.pins[:step])
        digital_write(Board::LOW, self.pins[:step])
      end
    end
  end
end
