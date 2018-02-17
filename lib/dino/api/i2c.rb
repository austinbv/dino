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
        aux = pack :uint8, [address, register, num_bytes]

        settings = options[:repeated_start] ? 1 : 0
        settings = settings | 0b10 unless register

        write Message.encode command: 35,
                             value: settings,
                             aux_message: aux
      end
    end
  end
end
