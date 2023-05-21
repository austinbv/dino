module Dino
  module SPI
    module Peripheral
      include Behaviors::OutputPin
      include Behaviors::Callbacks
      include Behaviors::BusPeripheral

      attr_reader :spi_frequency, :spi_mode, :spi_bit_order

      def before_initialize(options={})
        super(options)

        # Save SPI settings.
        @spi_frequency  = options[:spi_frequency]
        @spi_mode       = options[:spi_mode]
        @spi_bit_order  = options[:spi_bit_order]
      end

      #
      # Delegate methods to the bus.
      #
      def spi_transfer(write: [], read: 0)
        bus.transfer(pin, write: write, read: read, frequency: spi_frequency, mode: spi_mode, bit_order: spi_bit_order)
      end

      def spi_write(byte_array)
        bus.transfer(pin, write: byte_array, frequency: spi_frequency, mode: spi_mode, bit_order: spi_bit_order)
      end

      def spi_read(num_bytes)
        bus.transfer(pin, read: num_bytes, frequency: spi_frequency, mode: spi_mode, bit_order: spi_bit_order)
      end

      def spi_listen(num_bytes)
        bus.listen(pin, read: num_bytes, frequency: spi_frequency, mode: spi_mode, bit_order: spi_bit_order)
      end

      def spi_stop
        bus.stop(pin)
      end
    end
  end
end
