module Dino
  module API
    module I2C
      include Helper

      # CMD = 33
      def i2c_search
        write Message.encode command: 33
      end

      # CMD = 34
      def i2c_write(slave_address, data=[], options={})
        aux = pack :uint8, [slave_address, data.length, data].flatten
        write Message.encode command: 34,
                             value: options[:repeated_start] ? 1 : 0,
                             aux_message: aux
      end

      # CMD = 35
      def i2c_read(slave_address, register_start, num_bytes, options={})
        aux = pack :uint8, [slave_address, register_start, num_bytes]
        write Message.encode command: 35,
                             value: options[:repeated_start] ? 1 : 0,
                             aux_message: aux
      end
    end
  end
end
