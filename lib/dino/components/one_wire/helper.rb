module Dino
  module Components
    module OneWire
      class Helper
        #
        # Convert 64-bit Integer ROM address to array of 8 LSByte first bytes.
        #
        def self.address_to_bytes(address)
          [address].pack('<Q').split("").map(&:ord)
        end

        #
        # Remove the MSByte (CRC) and LSByte (family code) from a ROM address
        # to get the device's 48-bit serial number and convert to hex.
        #
        def self.address_to_serial(address)
          address = address & 0x00FFFFFFFFFFFFFF
          address = address >> 8
          address.to_s(16)
        end

        #
        # CRC is the last byte of any message. Start with it set to 0. Move through
        # the n-1 data bytes LSBYTE FIRST, but bitwise LSBFIRST. For each bit:
        #    1) XOR the bit with the current LSB of CRC
        #    2) XOR the result of #1 with the bits at indices 3 and 4 of CRC.
        #    3) Bitshift the CRC right by 1
        #    4) Write the result of #1 to the now empty MSB of the CRC
        # After 64 bits, the CRC is valid if it matches the 9th of the read data.
        #
        def self.crc_check(data)
          #
          # Sensor data will usually be an array of bytes, but for checking
          # things like ROM addresses, we may receive a 64-bit Integer.
          #
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
          crc == bytes.last
        end

        #
        # This separates a search result, checks result for device disconnection,
        # matches the family byte of the address to a Component class if one exists,
        # and looks for the highest index discrepancy to continue the search.
        #
        def self.parse_search_result(str)
          address, complement = self.split_search_result(str)

          #
          # If any address-complement bit-pair is 1-1, either no device is
          # present on the bus, or a device was disconnected during the search.
          #
          if (address & complement) > 0
            raise "OneWire device not connected or disconnected during search"
          end

          #
          # LS byte of the address holds the family code.
          # Lookup against implemented classes. Nil if no match.
          #
          klass = self.family_lookup(address & 0x00000000000000FF)

          #
          # XOR-ing address with complement gives a 0 bit at each discrepancy.
          # XOR again with 64 1s to flip to 1s. Ruby truncates leading 0 bits,
          # so MSB is the highest discrepancy. Result is -1 for no discrepancy.
          #
          # Note: The board only sends back discrepancies which we did not
          # set to 1 on the last search! This does not track all known
          # discrepancies in the address space, but gives us what we need:
          # The highest discrepancy that we didn't write a 1 for last time.
          #
          new_discrepancies = (address ^ complement) ^ 0xFFFFFFFFFFFFFFFF
          high_discrepancy = new_discrepancies.bit_length - 1

          [{class: klass, address: address}, high_discrepancy]
        end

        #
        # A search result is a comma separated list of 8 byte-pairs.
        # Each pair is an address byte, dash (-) separator, and complement byte.
        # Pairs are ordered LS byte first. Reverse to MS for easier bitshift.
        #
        def self.split_search_result(str)
          byte_pairs = str.split(",")
          address = 0
          complement = 0

          byte_pairs.reverse.each do |pair|
            address_byte, complement_byte = pair.split("-").map(&:to_i)
            address = (address << 8) | address_byte
            complement = (complement << 8) | complement_byte
          end

          if crc_check(address)
            return [address, complement]
          else
            raise "CRC error for device address on OneWire bus"
          end
        end

        #
        # Define FAMILY_CODE in a slave class to get it identified during search.
        #
        def self.family_lookup(family_code)
          OneWire.constants.each do |const|
            obj = OneWire.const_get(const)
            if (obj.is_a? Class) && (obj.const_defined? "FAMILY_CODE")
              return obj if obj::FAMILY_CODE == family_code
            end
          end
          return nil
        end
      end
    end
  end
end
