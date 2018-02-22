module Dino
  module Components
    module Register
      #
      # Model SPI registers as single pin. Data comes back on the select pin,
      # so just inherit from Select.
      #
      # options = {board: my_board, pin: slave_select_pin}
      #
      class SPIIn < Select
        include Input

        attr_reader :spi_mode, :frequency

        def after_initialize(options={})
          super(options) if defined?(super)
          
          @spi_mode  = options[:spi_mode]  || 0
          @frequency = options[:frequency] || 3000000
        end

        def read
          board.spi_transfer(pin, mode: spi_mode, frequency: frequency, read: @bytes)
        end

        def listen
          board.spi_listen(pin, mode: spi_mode, frequency: frequency, read: @bytes)
        end

        def stop
          board.spi_stop(pin)
        end
      end
    end
  end
end
