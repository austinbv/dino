module Dino
  module API
    module SPI
      include Helper

      def spi_header(options)
        options[:mode]       ||= 0
        options[:frequency]  ||= 3000000
        options[:bit_order]  ||= :lsbfirst
        raise ArgumentError,
              'invalid SPI mode' unless (0..3).include? options[:mode]

        # Flag unused high bit of mode if we need to transfer MSBFIRST.
        settings = options[:mode]
        settings = settings | 0b10000000 if options[:bit_order] == :msbfirst

        uint8 = pack(:uint8, [settings, options[:read], options[:write].length])
        uint8 + pack(:uint32, options[:frequency])
      end

      # CMD = 26
      def spi_transfer(pin, options={})
        options[:read] ||= 0
        if options[:write]
          options[:write] = [options[:write]].flatten
        else
          options[:write] = []
        end

        return if (options[:read] == 0) && (options[:write].empty?)

        header = spi_header(options)
        write Message.encode command: 26,
                             pin: pin,
                             aux_message: header + pack(:uint8, options[:write])
      end

      # CMD = 27
      def spi_listen(pin, options={})
        raise ArgumentError,
              'no SPI bytes to read' unless (options[:read] > 0)
        options[:write] = []

        header = spi_header(options)
        write Message.encode command: 27,
                             pin: pin,
                             aux_message: header
      end

      # CMD = 28
      def spi_stop(pin)
        write Message.encode command: 28, pin: pin
      end
    end
  end
end
