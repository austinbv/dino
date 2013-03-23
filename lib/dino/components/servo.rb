module Dino
  module Components
    class Servo < BaseComponent
      attr_reader :position

      def after_initialize(options={})
        set_pin_mode(:out)
        board.servo_toggle(pin, 1)
        position = options[:position] || 0
      end

      def position=(value)
        board.servo_write(pin, angle(value))
        @position = value
      end

      def angle(value)
        value == 180 ? value : value % 180
      end
    end
  end
end
