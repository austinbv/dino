module Dino
  module Components
    module OneWire
      class Helper
        #
        # CRC is a single byte. Start with it set to 0. Move through first 8
        # bytes in the order read, but bitwise LSBFIRST. For each bit:
        #    1) XOR the bit with the current LSB of CRC
        #    2) XOR the result of #1 with the bits at indices 3 and 4 of CRC.
        #    3) Bitshift the CRC right by 1
        #    4) Write the result of #1 to the now empty MSB of the CRC
        # After 64 bits, the CRC is valid if it matches the 9th of the read data.
        #
        def self.crc_check(bytes)
          crc = 0b00000000
          bytes.take(bytes.length - 1).each do |byte|
            for bit in (0..7)
              xor = byte[bit] ^ crc[0]
              crc = crc ^ ((xor * (2 ** 3)) | (xor * (2 ** 4)))
              crc = crc >> 1
              crc = crc | (xor * (2 ** 7))
            end
          end
          crc == bytes.last
        end
      end
    end
  end
end
