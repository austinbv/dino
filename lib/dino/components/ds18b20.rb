module Dino
  module Components
    class DS18B20
      include Setup::SinglePin
      include Mixins::Poller
      attr_reader :resolution

      def after_initialize(options={})
        super(options) if defined?(super)
        # default to 12 bit resolution here.
      end

      def resolution=
        # send commands to set resolution and store in instance variable
      end

      def pre_callback_filter(data)
        # Data will be 9 comma delimited bytes as ASCII numbers for now.
        bytes = data.split(",").map{|b| b.to_i}
        return {crc_error: true} unless crc_check(bytes)

        # Decode temperature from first 2 bytes.
        # Returns hash with C and F values.
        decode(bytes[1], bytes[0]).merge(raw: bytes, crc_error: false)
      end

      # Just store Celsius in @state?
      def self_update(hash)
        @state = hash[:c]
      end

      def crc_check(bytes)
        puts bytes.inspect
        crc = 0b00000000

        # Last byte IS the read CRC, so just use the first 8.
        bytes.take(8).each do |byte|
          # LSB first
          for bit in (0..7)
            # XOR current bit with the LSB of the CRC.
            xor = byte[bit] ^ crc[0]
            # XOR CRC bits 3 and 4 with first XOR result, then move right.
            crc = crc ^ ((xor * (2 ** 3)) | (xor * (2 ** 4)))
            crc = crc >> 1
            # Write first XOR result to the now empty MSB of the CRC.
            crc = crc | (xor * (2 ** 7)) # crc[7] = xor
          end
        end

        # Check against read CRC.
        crc == bytes.last
      end

      def decode(high_byte, low_byte)
        # Make one 16 bit value to work with.
        value = high_byte << 8 | low_byte

        # Two's complement, so if MSB is 1, value is -ve degrees C.
        negative = (value[15] == 1)

        # Get magnitude. Will reset sign after.
        value = (value ^ 0b1111_1111_1111_1111) + 1 if negative

        # Expand the exponents. LSB is 2^-4.
        celsius = 0.0
        exp = -4
        for bit in (0..10)
          celsius = celsius + (2.0 ** (exp+bit)) if (value[bit] == 1)
        end
        celsius = -celsius if negative
        farenheit = (celsius * 1.8 + 32).round(4)
        {c: celsius, f: farenheit}
      end

      def _read
        # bus.synchronize do
        reset
        skip_rom
        convert
        # end

        # Wait for A/D conversion in Ruby. Won't block the bus or the board.
        # Should scale inversely with resolution. Divide by 2 per bit of resolution.
        sleep(0.75)

        # bus.synchronize do
        reset
        skip_rom
        scratch_read
        bus_read(9)
        # end
      end

      def reset
        board.write Dino::Message.encode(command: 41, pin: pin)
      end

      def bus_read(num_bytes)
        board.write Dino::Message.encode(command: 44, pin: pin, value: num_bytes)
      end

      def scratch_read
        write(0xBE)
      end

      def skip_rom
        write(0xCC)
      end

      def convert
        write(0x44)
      end

      def write(*bytes)
        bytes = bytes.flatten
        raise ArgumentError, "wrong number of arguments (given 0, expected at least 1)" if bytes.empty?

        length = bytes.length
        bytes = bytes.pack('C*')
        board.write Dino::Message.encode(command: 43, pin: pin, value: length, aux_message: bytes)
      end
    end
  end
end
