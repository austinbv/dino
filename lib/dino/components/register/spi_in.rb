module Dino
  module Components
    module Register
      class SPIIn < Select
        include Input

        #
        # Model SPI registers as single pin. Data comes back on the select pin,
        # so just inherit from Select.
        #
        # options = {board: my_board, pin: slave_select_pin}
        #
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
          start_address = 0
          aux = "#{[start_address, @spi_mode].pack('C*')}#{[@frequency].pack('V')}"
          board.write Dino::Message.encode(command: 27, pin: pin, value: @bytes, aux_message: aux)
        end

        def listen
          # Pack the extra parameters we need to send in the aux message then send.
          start_address = 0
          aux = "#{[start_address, @spi_mode].pack('C*')}#{[@frequency].pack('V')}"
          board.write Dino::Message.encode(command: 28, pin: pin, value: @bytes, aux_message: aux)
        end

        def stop
          # Just need to send the select pin to stop listening.
          board.write Dino::Message.encode(command: 29, pin: pin)
        end
      end
    end
  end
end
