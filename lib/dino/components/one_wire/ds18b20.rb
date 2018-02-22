module Dino
  module Components
    module OneWire
      class DS18B20 < Slave
        FAMILY_CODE = 0x28

        def scratch
          @state ? @state[:raw] : read_scratch(9)
        end

        def resolution
          @resolution ||= decode_resolution(scratch)
        end

        def resolution=(bits)
          unless (9..12).include?(bits)
            raise ArgumentError, 'Invalid DS18B20 resolution, expected 9 to 12'
          end

          return bits if decode_resolution(scratch) == bits

          eeprom = scratch[2..4]
          eeprom[2] = 0b00011111 | ((bits - 9) << 5)
          write_scratch(eeprom)
          copy_scratch
          @resolution = bits
        end

        def set_convert_time
          @convert_time = 0.75 / (2 ** (12 - @resolution))
        end

        def convert
          @resolution ||= 12
          set_convert_time

          atomically do
            match
            bus.write(CONVERT_T)
            sleep @convert_time if bus.parasite_power
          end
          sleep @convert_time unless bus.parasite_power
        end

        def _read
          convert
          read_scratch(9) { |data| self.update(data) }
        end

        def pre_callback_filter(bytes)
          return { crc_error: true } unless Helper.crc_check(bytes)
          @resolution = decode_resolution(bytes)

          decode_temperature(bytes).merge(raw: bytes)
        end

        #
        # Temperature is the first 16 bits (2 bytes of 9 read).
        # It's a signed, 2's complement, little-endian decimal. LSB = 2 ^ -4.
        #
        def decode_temperature(bytes)
          celsius = bytes[0..1].pack('C*').unpack('s<')[0] * (2.0 ** -4)
          farenheit = (celsius * 1.8 + 32).round(4)

          {celsius: celsius, farenheit: farenheit}
        end

        def decode_resolution(bytes)
          config_byte = bytes[4]
          offset = config_byte >> 5
          offset + 9
        end
      end
    end
  end
end
