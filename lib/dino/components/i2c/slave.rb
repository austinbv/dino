module Dino
  module Components
    module I2C
      class Slave
        include Mixins::BusSlave
        include Mixins::Poller

        def repeated_start
          false
        end

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
