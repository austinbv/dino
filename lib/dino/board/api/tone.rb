module Dino
  module Board
    module API
      module Tone
        include Helper
        
        # CMD = 17
        def tone(pin, frequency, duration=nil)
          raise ArgumentError, "Tone cannot generate frequencies lower than 31Hz"     if frequency < 31
          raise ArgumentError, "Tone duration cannot be more than 65535 milliseconds" if (duration && (duration > 0xFFFF))

          # Pack the frequency and optional duration as binary.
          aux = pack(:uint16, frequency)
          aux << pack(:uint16, duration) if duration

          write Message.encode command: 17,
                                    pin: pin,
                                    value: duration ? 1 : 0,
                                    aux_message: aux
        end

        # CMD = 18
        def no_tone(pin)
          write Message.encode command: 18, pin: pin
        end
      end
    end
  end
end
