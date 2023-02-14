module Dino
  module Components
    module Register
      #
      # Model SPI registers as single pin. MOSI and MISO are shared
      # and predetermined, so we only need to care about the select pin.
      #
      # options = {board: my_board, pin: register_select_pin}
      #
      class SPIIn < Select
        include Input

        attr_reader :spi_mode, :frequency, :bit_order

        def initialize(options)
          super(options)
          @spi_mode  = options[:spi_mode]  || 0
          @frequency = options[:frequency] || 1000000
          @bit_order = options[:bit_order] || :msbfirst
        end

        def read
          board.spi_transfer(pin, mode: @spi_mode, frequency: frequency, read: @bytes, bit_order: @bit_order)
        end

        def listen
          board.spi_listen(pin, mode: @spi_mode, frequency: frequency, read: @bytes, bit_order: @bit_order)
        end

        def stop
          board.spi_stop(pin)
        end
      end
    end
  end
end
