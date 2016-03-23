module Dino
  module Components
    class Servo
      include Setup::SinglePin
      include Mixins::Threaded
      
      def after_initialize(options={})
        board.servo_toggle(pin, 1)
      end

      def position=(value)
        @state = angle(value)
        board.servo_write(pin, @state)
      end

      alias :position :state

      def angle(value)
        value == 180 ? value : value % 180
      end
    end
  end
end
