module Dino
  module Board
    module API
      module SPIBitBang
        include Helper

        def spi_validate(options)
          options[:read]       ||= 0
          options[:write]        = [options[:write]].flatten.compact || []
          options[:mode]       ||= 0
          options[:bit_order]  ||= :msbfrst

          # Lowest 2 bits of settings control the SPI mode
          settings =  options[:mode] 
          unless (0..3).include? settings
            raise ArgumentError, "invalid SPI mode. Must be 0, 1, 2, or 3"
          end

          # Bit 7 of settings toggles MSBFIRST (1) or LSBFIRST (0) for both read and write.
          settings = settings | 0b10000000 unless options[:bit_order] == :lsbfirst

          # Validate byte lengths.
          raise ArgumentError, "can't read more than 255 SPI bytes at a time" if options[:read] > 255
          raise ArgumentError, "can't write more than 255 SPI bytes at a time" if options[:write].length > 255

          return settings, options
        end

        def spi_bb_header(options)
          settings, options = spi_validate(options)

          # Validate input or output pin.
          unless options[:input] || options[:output]
            raise ArgumentError, "no input or output pin given. Require either or both"
          end

          # Validate clock pin.
          raise ArgumentError, "no clock pin given" unless options[:clock]

          # Pack the header as the board expects it.
          header = pack :uint8, [settings, options[:read], options[:write].length, options[:clock], options[:input], options[:output], 0]

          [header, options]
        end

        # CMD = 21
        def spi_bb_transfer(select_pin, options={})
          header, options = spi_bb_header(options)

          if (options[:read] == 0) && (options[:write].empty?)
            raise ArgumentError, "no bytes given to read or write"
          end
          
          write Message.encode  command: 21,
                                pin: select_pin,
                                aux_message: header + pack(:uint8, options[:write])
        end

        # CMD = 22
        def spi_bb_listen(select_pin, options={})
          header, options = spi_bb_header(options)
          
          raise ArgumentError, 'no bytes to read' unless (options[:read] > 0)

          write Message.encode  command: 22,
                                pin: select_pin,
                                aux_message: header
        end

        # CMD = 23
        def spi_bb_stop(select_pin)
          write Message.encode command: 23, pin: select_pin
        end
      end
    end
  end
end
