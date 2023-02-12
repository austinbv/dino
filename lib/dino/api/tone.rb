module Dino
  module API
    module Tone
      include Helper
      
      def tone(pin, frequency, duration=nil)
        if frequency < 31
          raise ArgumentError, "Tone cannot generate frequencies lower than 31Hz"
        end
        
        # Pack the frequency and optiona duration as binary.
        aux = pack(:uint16, frequency)
        aux << pack(:uint32, duration) if duration

        write Dino::Message.encode command: 17,
                                   pin: convert_pin(pin),
                                   value: duration ? 1 : 0,
                                   aux_message: aux
      end

      def no_tone(pin)
        write Message.encode command: 18, pin: convert_pin(pin)
      end
    end
  end
end
