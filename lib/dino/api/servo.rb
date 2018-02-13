module Dino
  module API
    module Servo
      include Helper

      def servo_toggle(pin, value=:off)
        write Message.encode command: 8,
                             pin: convert_pin(pin),
                             value: (value == :off) ? 0 : 1
      end

      def servo_write(pin, value=0)
        write Message.encode command: 9,
                             pin: convert_pin(pin),
                             value: value
      end
    end
  end
end
