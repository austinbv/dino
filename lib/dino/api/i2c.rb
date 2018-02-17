module Dino
  module API
    module I2C
      include Helper

      # CMD = 33
      def i2c_search
        write Message.encode command: 33
      end

      # CMD = 34
      def i2c_write(address, bytes=[], options={})
        aux = pack :uint8, [address, bytes.length, bytes].flatten
        write Message.encode command: 34,
                             value: options[:repeated_start] ? 1 : 0,
                             aux_message: aux
      end

      # CMD = 35
      def i2c_read(address, register, num_bytes, options={})
        settings = options[:repeated_start] ? 1 : 0

        # Won't write anything if no start register was given.
        unless register
          settings = settings | 0b10
          register = 0
        end

        aux = pack :uint8, [address, register, num_bytes]
        write Message.encode command: 35,
                             value: settings,
                             aux_message: aux
      end
    end
  end
end
