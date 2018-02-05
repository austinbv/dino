module Dino
  module Components
    module OneWire
      class DS18B20
        include Setup::Base
        include Mixins::Poller

        FAMILY_CODE = 0x28

        attr_reader :resolution, :address
        alias  :bus :board

        def after_initialize(options={})
          super(options) if defined?(super)
          # Should set only if given as parameter.
          # If not, read from sensor and leave as is.
          self.resolution = 12

          raise "missing ROM address for 1-Wire device, try searching first" unless options[:address]
          @address = options[:address]
        end

        def resolution
          # Read scratchpad and resolution from sensor here.
        end

        def serial
          Helper.address_to_serial(self.address)
        end

        def resolution=(bits)
          raise 'Invalid resolution for DS18B20 sensor' if (bits > 12 || bits < 9)
          @resolution = bits
          # Send commands to set resolution here.
          @convert_time = 0.75 / (13 - bits)
        end

        #
        # If we're the only device on the bus, save time by skipping ROM match.
        #
        def identify
          bus.reset
          if bus.found_devices == 1
            bus.write(SKIP_ROM)
          else
            bus.write(MATCH_ROM)
            bus.write(Helper.address_to_bytes(self.address))
          end
        end

        def convert
          bus.mutex.synchronize do
            identify
            bus.write(CONVERT_T)
            sleep @convert_time if bus.parasite_power
          end
          sleep @convert_time unless bus.parasite_power
        end

        def read_scratch
          data = nil
          bus.mutex.synchronize do
            identify
            bus.write(READ_SCRATCH)
            data = bus.read(9)
          end
          data
        end

        def _read
          convert
          reading = read_scratch
          # This runs callbacks in our thread instead of the callback thread...
          self.update(reading)
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
