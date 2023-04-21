module Dino
  module Board
    module API
      module I2C
        include Helper

        # CMD = 33
        def i2c_search
          write Message.encode command: 33
        end

        # CMD = 34
        def i2c_write(address, bytes=[], options={})
          raise ArgumentError, 'I2C write must be 1..32 bytes long' if (bytes.length > 32 || bytes.length < 1)
          
          # Use top bit of address to select stop condition (1), or repated start (0).
          send_stop = options[:repeated_start] ? 0 : 1

          write Message.encode  command:     34,
                                pin:         address | (send_stop << 7),
                                value:       bytes.length,
                                aux_message: pack(:uint8, [bytes].flatten)
        end

        # CMD = 35
        def i2c_read(address, register, read_length, options={})
          raise ArgumentError, 'I2C read must be 1..32 bytes long' if (read_length > 32 || read_length < 1)

          # Use top bit of address to select stop condition (1), or repated start (0).
          send_stop = options[:repeated_start] ? 0 : 1

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
                                aux_message:  aux
        end
      end
    end
  end
end
