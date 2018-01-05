module Dino
  module Components
    module Register
      class SPIOut < Select
        include Output
        #
        # Model SPI registers as single pin. Data comes back on the select pin,
        # so just inherit from Select.
        #
        # options = {board: my_board, pin: slave_select_pin}
        #

        def after_initialize(options={})
          # Save SPI device settings in instance variables.
          @spi_mode  = options[:spi_mode] || 0

          # No default value for clock frequency.
          raise 'SPI clock rate (Hz) required in :frequency option' unless options[:frequency]
          @frequency = options[:frequency]

          super(options) if defined?(super)
        end

        #
        # Write using a call to the native SPI library.
        #
        def write(*bytes)
          # Pack the extra parameters we need to send in the aux message then send.
          aux = bytes.flatten
          length = aux.count
          aux = "#{[@spi_mode].pack('C')}#{[@frequency].pack('V')}#{aux.pack('C*')}"

          board.write Dino::Message.encode(command: 26, pin: pin, value: length, aux_message: aux)
        end
      end
    end
  end
end
