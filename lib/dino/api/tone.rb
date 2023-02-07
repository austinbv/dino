module Dino
  module API
    module Tone
      include Helper

      # value = tone frequency in Hz (should be sent as binary to allow higher than 9999, and limit to above 30Hz)
      # duration = tone duration in ms
      # duration currently sent as string. Should be binary and max limited to uint32
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
