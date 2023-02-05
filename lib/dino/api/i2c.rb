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
        
        # Bit 1 of settings controls repeated start.
        settings  = 0b00
        settings |= 0b01 if options[:repeated_start]
        
        aux = pack :uint8, [address, 0, bytes.length, bytes].flatten
        write Message.encode command: 34,
                             value: settings,
                             aux_message: aux
      end

      # CMD = 35
      def i2c_read(address, register, num_bytes, options={})
        raise ArgumentError, 'maximum read length from I2C devices is 32 bytes' if num_bytes > 32
        
        # Bit 1 of settings controls repeated start.
        settings  = 0b00
        settings |= 0b01 if options[:repeated_start]
        
        # Bit 2 of settings controls whether to write a start register before reading.
        settings |= 0b10 if register

        aux = pack :uint8, [address, 0, register, num_bytes]
        write Message.encode command: 35,
                             value: settings,
                             aux_message: aux
      end
    end
  end
end
