module Dino
  module Components
    module I2C
      class Slave
        include Mixins::BusSlave
        include Mixins::Reader

        def before_initialize(options)
          super(options)
          @repeated_start = options[:repeated_start] || false
        end
        
        attr_accessor :repeated_start
        
        def write(bytes=[])
          bus.write(address, bytes, repeated_start: repeated_start)
        end

        def read_bytes(register, num_bytes=1)
          bus.read(address, register, num_bytes, repeated_start: repeated_start)
        end
      end
    end
  end
end
