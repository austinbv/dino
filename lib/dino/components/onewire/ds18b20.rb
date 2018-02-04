module Dino
  module Components
    module OneWire
      class DS18B20
        include Setup::Base
        include Mixins::Poller
        attr_reader :resolution, :parasite_power

        alias  :bus :board

        def after_initialize(options={})
          super(options) if defined?(super)
          # Should set only if given as parameter.
          # If not, read from sensor and leave as is.
          self.resolution = 12
        end

        def resolution
          # Read scratchpad and resolution from sensor here.
        end

        def resolution=(bits)
          raise 'Invalid resolution for DS18B20 sensor' if (bits > 12 || bits < 9)
          @resolution = bits
          # Send commands to set resolution here.
          @convert_time = 0.75 / (13 - bits)
        end

        def _read
          bus.mutex.synchronize do
            bus.reset
            bus.write(SKIP_ROM, CONVERT_T)
            sleep @convert_time if bus.parasite_power
          end

          sleep @convert_time unless bus.parasite_power
          data = nil

          bus.mutex.synchronize do
            bus.reset
            bus.write(SKIP_ROM, READ_SCRATCH)
            data = bus.read(9)
          end

          # Once we got data, free the bus and run callbacks ourselves.
          self.update(data)
        end

        #
        # Data comes in as 9 comma delimited bytes in ASCII numbers.
        # First 2 bytes are a coded little-endian number containing degrees C.
        # Check CRC first. If good, decode and pass on degrees C, F and raw data.
        #
        def pre_callback_filter(data)
          bytes = data.split(",").map{|b| b.to_i}
          return {crc_error: true} unless Helper.crc_check(bytes)

          decode(bytes[1], bytes[0]).merge(raw: bytes)
        end

        #
        # Temperature is the first 16 bits (2 bytes of 9 read), little-endian.
        # It's a sign-extended two's complement 11-bit decimal, where LSB is the
        # 2^-4 exponent, up through 2^6 for bit 11. The 5 MSBs repeat the sign.
        #
        def decode(high_byte, low_byte)
          # Concatenate to 16-bit and reverse two's complement if necessary.
          value = high_byte << 8 | low_byte
          negative = (value[15] == 1)
          value = (value ^ 0xFFFF) + 1 if negative

          # Expand the exponents, restore sign, and convert to Farenheit.
          celsius = 0.0; exp = -4
          for bit in (0..10)
            celsius = celsius + (2.0 ** (exp+bit)) if (value[bit] == 1)
          end
          celsius = -celsius if negative
          farenheit = (celsius * 1.8 + 32).round(4)

          {celsius: celsius, farenheit: farenheit}
        end
      end
    end
  end
end
