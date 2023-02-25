module Dino
  module Components
    module Register
      #
      # Model SPI registers as single pin. MOSI and MISO are shared
      # and predetermined, so we only need to care about the select pin.
      #
      # options = {board: my_board, pin: register_select_pin}
      #
      class SPIOut < Select
        include Output

        attr_reader :spi_mode, :frequency, :bit_order

        def before_initialize(options)
          super(options)
          @spi_mode  = options[:spi_mode]  || 0
          @frequency = options[:frequency] || 1000000
          @bit_order = options[:bit_order] || :msbfirst
        end

        def write(*bytes)
          board.spi_transfer(pin, mode: spi_mode, frequency: frequency, write: bytes.flatten, bit_order: bit_order)
        end
      end
    end
  end
end
