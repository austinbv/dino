module Dino
  module API
    module OneWire
      include Helper

      def one_wire_reset(pin, value=0)
        write Message.encode command: 41,
                             pin: convert_pin(pin),
                             value: value
      end

      def one_wire_search(pin, branch_mask)
        write Message.encode command: 42,
                             pin: convert_pin(pin),
                             aux_message: pack(:uint64, branch_mask, max: 8)
      end

      def one_wire_write(pin, parasite_power, *data)
        bytes  = pack :uint8, data, min: 1, max: 127 # Should be 128 with 0 = 1.

        # Set high bit of length if the bus must drive high after write.
        length = bytes.length
        length = length | 0b10000000 if parasite_power

        write Message.encode command: 43,
                             pin: convert_pin(pin),
                             value: length,
                             aux_message: bytes
      end

      def one_wire_read(pin, num_bytes)
        write Message.encode command: 44,
                             pin: convert_pin(pin),
                             value: num_bytes
      end
    end
  end
end
