module Dino
  module API
    module Servo
      include Helper

      def servo_toggle(pin, value=:off, options={})
        options[:min] ||= 544
        options[:max] ||= 2400
        aux = pack :uint16, [options[:min], options[:max]]

        write Message.encode command: 8,
                             pin: convert_pin(pin),
                             value: (value == :off) ? 0 : 1,
                             aux_message: aux
      end

      def servo_write(pin, value=0)
        write Message.encode command: 9,
                             pin: convert_pin(pin),
                             aux_message: pack(:uint16, value)
      end
    end
  end
end
