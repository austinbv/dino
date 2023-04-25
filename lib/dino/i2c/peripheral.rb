module Dino
  module I2C
    class Peripheral
      include Behaviors::BusPeripheralAddressed
      include Behaviors::Reader

      def before_initialize(options)
        @repeated_start = options[:i2c_repeated_start] || false
        @speed          = options[:i2c_frequency]      || 100000

        # Allow generic :address option to be given as :i2c_address before validation.
        options[:address] ||= options[:i2c_address]

        super(options)
      end
      
      attr_accessor :i2c_repeated_start, :i2c_frequency

      def i2c_address
        self.address
      end
      
      def write(bytes=[])
        bus.write(address, bytes, i2c_repeated_start: i2c_repeated_start, i2c_frequency: i2c_frequency)
      end

      def _read(register, num_bytes)
        bus.read(address, register, num_bytes, i2c_repeated_start: i2c_repeated_start, i2c_frequency: i2c_frequency)
      end
    end
  end
end
