module Dino
  module Board
    module API
      module I2C
        include Helper

        I2C_FREQUENCIES = {
          100000  => 0x00,
          400000  => 0x01,
          1000000 => 0x02,
          3400000 => 0x03,
        }

        # Might make this bigger based on board maps later, but stick with the lowest limit of the AVR boards for now.
        def i2c_limit
          32
        end

        def i2c_convert_frequency(freq)
          # Default to 100 kHz.
          freq = 100000 unless freq

          unless I2C_FREQUENCIES.include?(freq)
            raise ArgumentError, "I2C frequency must be in: #{I2C_FREQUENCIES.keys.inspect}" 
          end
          I2C_FREQUENCIES[freq]
        end

        # CMD = 33
        def i2c_search
          write Message.encode command: 33
        end

        # CMD = 34
        def i2c_write(address, bytes=[], options={})
          raise ArgumentError, "I2C write must be 1..#{i2c_limit} bytes long" if (bytes.length > i2c_limit || bytes.length < 1)
          
          # Use top bit of address to select stop condition (1), or repated start (0).
          send_stop = options[:i2c_repeated_start] ? 0 : 1
          freq = i2c_convert_frequency(options[:i2c_frequency])

          write Message.encode  command:     34,
                                pin:         address | (send_stop << 7),
                                value:       bytes.length,
                                aux_message: pack(:uint8, freq) + pack(:uint8, [bytes].flatten)
        end

        # CMD = 35
        def i2c_read(address, register, read_length, options={})
          raise ArgumentError, "I2C read must be 1..#{i2c_limit} bytes long" if (read_length > i2c_limit || read_length < 1)

          # Use top bit of address to select stop condition (1), or repated start (0).
          send_stop = options[:i2c_repeated_start] ? 0 : 1

          # Default to 100 kHz.
          options[:speed] ||= 100000
          freq = i2c_convert_frequency(options[:i2c_frequency])

          # A starting register can be optionally given, up to 4 bytes as an array.
          if register
            register = [register].flatten 
            raise ArgumentError, 'maximum 4 byte register address for I2C read' if register.length > 4
            aux = pack(:uint8, [register.length] + register)
          else
            aux = pack(:uint8, [0])
          end

          write Message.encode  command:      35,
                                pin:          address | (send_stop << 7),
                                value:        read_length,
                                aux_message:  pack(:uint8, freq) + aux
        end
      end
    end
  end
end
