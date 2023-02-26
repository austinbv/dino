module Dino
  module Components
    module OneWire
      class Helper
        def self.address_to_bytes(address)
          [address].pack('Q<').split("").map(&:ord)
        end

        def self.crc_check(data)
          calculated, received = self.calculate_crc(data)
          calculated == received
        end
        
        def self.calculate_crc(data)
          if data.class == Integer
            bytes = address_to_bytes(data)
          else
            bytes = data
          end

          crc = 0b00000000
          bytes.take(bytes.length - 1).each do |byte|
            for bit in (0..7)
              xor = byte[bit] ^ crc[0]
              crc = crc ^ ((xor * (2 ** 3)) | (xor * (2 ** 4)))
              crc = crc >> 1
              crc = crc | (xor * (2 ** 7))
            end
          end
          [crc, bytes.last]
        end
      end
    end
  end
end
