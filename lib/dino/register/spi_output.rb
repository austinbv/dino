module Dino
  module Register
    #
    # Model SPI registers as single pin. MOSI and MISO are shared
    # and predetermined, so we only need to care about the select pin.
    #
    # options = {board: my_board, pin: register_select_pin}
    #
    class SPIOutput < ChipSelect
      include Output

      attr_reader :spi_mode, :frequency, :bit_order

      def before_initialize(options)
        super(options)
        @spi_mode  = options[:spi_mode]
        @frequency = options[:frequency]
        @bit_order = options[:bit_order]
      end

      def write(*bytes)
        bus.transfer(pin, mode: spi_mode, frequency: frequency, write: bytes.flatten, bit_order: bit_order)
      end
    end
  end
end
