module Dino
  module Components
    module Register
      class SPIIn < Select
        #
        # options = {board: my_board, pin: slave_select_pin}
        #
        include Input

        def after_initialize(options={})
          super(options) if defined?(super)

          # Save SPI device settings in instance variables.
          @spi_mode  = options[:spi_mode]  || 0

          # No default value for clock frequency.
          raise 'SPI clock rate (Hz) required in :frequency option' unless options[:frequency]
          @frequency = options[:frequency]
        end

        #
        # Read using a call to the native SPI library.
        #
        def read
          # Pack the extra parameters we need to send in the aux message then send.
          aux = "#{[@spi_mode].pack('C')}#{[@frequency].pack('V')}"
          board.write Dino::Message.encode(command: 25, pin: pin, value: @bytes, aux_message: aux)
        end
      end
    end
  end
end
