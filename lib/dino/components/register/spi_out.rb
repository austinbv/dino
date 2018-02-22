module Dino
  module Components
    module Register
      #
      # Model SPI registers as single pin. Data comes back on the select pin,
      # so just inherit from Select.
      #
      # options = {board: my_board, pin: slave_select_pin}
      #
      class SPIOut < Select
        include Output

        attr_reader :spi_mode, :frequency

        def after_initialize(options={})
          @spi_mode  = options[:spi_mode]  || 0
          @frequency = options[:frequency] || 3000000

          super(options) if defined?(super)
        end

        def write(*bytes)
          board.spi_transfer(pin, mode: spi_mode, frequency: frequency, write: bytes.flatten)
        end
      end
    end
  end
end
