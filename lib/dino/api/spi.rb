module Dino
  module API
    module SPI
      include Helper

      def spi_settings(mode, frequency)
        pack(:uint8, [0, mode]) + pack(:uint32, [frequency])
      end

      # Listener can store up to 8 bytes to get written each time, read up to 256.
      def spi_write(pin, mode, frequency, bytes)
        settings = spi_settings(mode, frequency)
        bytes = pack(:uint8, bytes)
        write Message.encode command: 26,
                             pin: pin,
                             value: bytes.length,
                             aux_message: settings + bytes
      end

      def spi_read(pin, mode, frequency, num_bytes)
        write Message.encode command: 27,
                             pin: pin,
                             value: num_bytes,
                             aux_message: spi_settings(mode, frequency)
      end

      def spi_listen(pin, mode, frequency, num_bytes)
        write Message.encode command: 28,
                             pin: pin,
                             value: num_bytes,
                             aux_message: spi_settings(mode, frequency)
      end

      def spi_stop(pin)
        write Message.encode command: 29, pin: pin
      end
    end
  end
end
