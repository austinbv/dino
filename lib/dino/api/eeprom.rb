module Dino
  module API
    module EEPROM
      include Helper

      # CMD = 6
      def eeprom_read(address, num_bytes)
        address = pack :uint16, address
        write Message.encode command: 6,
                             value: num_bytes,
                             aux_message: address
      end

      # CMD = 7
      def eeprom_write(address, bytes=[])
        address = pack :uint16, address
        bytes  = pack :uint8, bytes, min: 1, max: 128
        write Message.encode command: 7,
                             value: bytes.length,
                             aux_message: address + bytes
      end
    end
  end
end
