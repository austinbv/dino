module Dino
  class Board
    def infrared_emit(pin, frequency, pulses)
      #
      # Limit to 255 marks/spaces (not pairs) for now.
      #
      # Length must be 1-byte long, not literally 1
      # Pulses max is 2x255 bytes long since each is 2 bytes.
      length = pack :uint8,  pulses.length,  max: 1
      bytes  = pack :uint16, pulses, min: 1, max: 510

      write Message.encode command: 16,
                          pin: pin,
                          value: frequency,
                          aux_message: length + bytes
    end
  end
end
