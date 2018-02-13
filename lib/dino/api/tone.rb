module Dino
  module API
    module Tone
      include Helper

      def tone(pin, value, duration)
        write Dino::Message.encode command: 17,
                                   pin: convert_pin(pin),
                                   value: value,
                                   aux_message: duration
      end

      def no_tone(pin)
        write Message.encode command: 18, pin: convert_pin(pin)
      end
    end
  end
end
