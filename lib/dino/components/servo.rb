module Dino
  module Components
    class Servo < Core::BaseOutput
      def after_initialize(options={})
        board.servo_toggle(pin, 1)
      end

      def position=(value)
        @state = angle(value)
        board.servo_write(pin, @state)
      end

      def position
        @state
      end

      def angle(value)
        value == 180 ? value : value % 180
      end
    end
  end
end
