module Dino
  module Register
    #
    # Model SPI registers as single pin. MOSI and MISO are shared
    # and predetermined, so we only need to care about the select pin.
    #
    # options = {board: my_board, pin: register_select_pin}
    #
    class SPIInput < ChipSelect
      include Input

      attr_reader :spi_mode, :frequency, :bit_order

      def initialize(options)
        super(options)
        @spi_mode  = options[:spi_mode]
        @frequency = options[:frequency]
        @bit_order = options[:bit_order]
      end

      def read
        bus.transfer(pin, mode: @spi_mode, frequency: frequency, read: @bytes, bit_order: @bit_order)
      end

      def listen
        bus.listen(pin, mode: @spi_mode, frequency: frequency, read: @bytes, bit_order: @bit_order)
      end

      def stop
        bus.stop(pin)
      end
    end
  end
end
