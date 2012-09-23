module Dino
  module Components
    class Servo < BaseComponent
      attr_reader :position

      def initialize(options)
        super(options)

        set_pin_mode(:out)
        self.position = 0
      end

      def position=(new_position)
        @position = new_position % 180
        analog_write(@position)
      end
    end
  end
end

