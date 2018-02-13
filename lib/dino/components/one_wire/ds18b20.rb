module Dino
  module Components
    module OneWire
      class DS18B20 < Slave

        FAMILY_CODE = 0x28

        def resolution
          @resolution ||= decode_resolution read_scratch(9)
        end

        def resolution=(bits)
          raise ArgumentError 'Invalid DS18B20 resolution' if (bits > 12 || bits < 9)

          @resolution = bits
          scratch = read_scratch(9).split(",").map(&:to_i)

          unless decode_resolution(scratch) == @resolution
            settings = scratch[2..4]
            offset = @resolution - 9
            settings[2] = 0b00011111 | (offset << 5)
            write_scratch(settings)
            copy_scratch
          end

          set_convert_time
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
          read_scratch(9)
        end

        def pre_callback_filter(data)
          # Data is 9 comma delimited numbers in ASCII, representing bytes.
          bytes = data.split(",").map{ |b| b.to_i }
          return {crc_error: true} unless Helper.crc_check(bytes)

          @resolution = decode_resolution(bytes)

          decode_temp(bytes).merge(raw: bytes)
        end

        #
        # Temperature is the first 16 bits (2 bytes of 9 read), little-endian.
        # It's a sign-extended two's complement 12-bit decimal, where LSB is the
        # 2^-4 exponent, up through 2^6 for next 10 bits. 5 MSBs repeat the sign.
        #
        def decode_temp(bytes)
          magnitude = bytes[1] << 8 | bytes[0]
          negative = (magnitude[15] == 1)
          magnitude = (magnitude ^ 0xFFFF) + 1 if negative

          celsius = 0.0
          exp = -4
          for bit in (0..10)
            if (magnitude[bit] == 1)
              celsius = celsius + (2.0 ** (exp+bit))
            end
          end

          celsius = -celsius if negative
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
