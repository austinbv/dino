module Dino
  module I2C
    module Peripheral
      include Behaviors::BusPeripheralAddressed
      include Behaviors::Reader

      def before_initialize(options)
        @i2c_frequency      = options[:i2c_frequency]      || 100000
        @i2c_repeated_start = options[:i2c_repeated_start] || false

        # Allow generic :address option to be given as :i2c_address before validation.
        options[:address] ||= options[:i2c_address]

        super(options)
      end
      
      attr_accessor :i2c_repeated_start, :i2c_frequency
      alias :i2c_address :address 

      def i2c_write(bytes=[])
        bus.write(address, bytes, i2c_frequency, i2c_repeated_start)
      end

      def i2c_read(register, num_bytes)
        bus.read(address, register, num_bytes, i2c_frequency, i2c_repeated_start)
      end
    end
  end
end
