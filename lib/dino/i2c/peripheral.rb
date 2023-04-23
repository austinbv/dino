module Dino
  module I2C
    class Peripheral
      include Behaviors::BusPeripheral
      include Behaviors::BusAddressable
      include Behaviors::Reader

      def before_initialize(options)
        super(options)
        @repeated_start = options[:repeated_start] || false
        @speed = options[:speed] || 100000
      end
      
      attr_accessor :repeated_start, :speed
      
      def write(bytes=[])
        bus.write(address, bytes, repeated_start: repeated_start, speed: speed)
      end

      def _read(register, num_bytes)
        bus.read(address, register, num_bytes, repeated_start: repeated_start, speed: speed)
      end
    end
  end
end
