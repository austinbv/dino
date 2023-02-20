module Dino
  module API
    module Infrared
      include Helper

      def infrared_emit(pin, frequency, pulses)
        # Need to start using length - 1, but doesn't work on board yet.
        # 0 = 1 pulse, 255 = 256 pulses.
        length = pack :uint8,  pulses.length,  max: 1
        bytes  = pack :uint16, pulses, min: 1, max: 512

        write Message.encode command: 16,
                             pin: convert_pin(pin),
                             value: frequency,
                             aux_message: length + bytes
      end
    end
  end
end
