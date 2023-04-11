module Dino
  module Board
    module API
      module SPI
        include Helper

        def spi_header(options)
          options[:read]       ||= 0
          options[:write]        = [options[:write]].flatten.compact || []
          options[:mode]       ||= 0
          options[:frequency]  ||= 1000000
          options[:bit_order]  ||= :msbfrst
                    
          # Lowest 2 bits of settings control the SPI mode
          settings =  options[:mode] 
          unless (0..3).include? settings
            raise ArgumentError, "invalid SPI mode. Must be 0, 1, 2, or 3"
          end
          
          # Bit 7 of settings toggles MSBFIRST (1) or LSBFIRST (0) transmission order.
          settings = settings | 0b10000000 unless options[:bit_order] == :lsbfirst
          
          raise ArgumentError, "can't read more than 255 SPI bytes at a time" if options[:read] > 255
          raise ArgumentError, "can't write more than 255 SPI bytes at a time" if options[:write].length > 255
          header = pack :uint8, [settings, options[:read], options[:write].length]

          raise ArgumentError, "invalid SPI frequency" unless [Integer, Float].include? options[:frequency].class
          header = header + pack(:uint32, options[:frequency])

          [header, options]
        end

        # CMD = 26
        def spi_transfer(pin, options={})
          header, options = spi_header(options)
          
          if (options[:read] == 0) && (options[:write].empty?)
            raise ArgumentError, "no SPI bytes to read or write given"
          end
          
          write Message.encode  command: 26,
                                pin: pin,
                                aux_message: header + pack(:uint8, options[:write])
        end

        # CMD = 27
        def spi_listen(pin, options={})
          header, options = spi_header(options)
          
          raise ArgumentError, 'no SPI bytes to read' unless (options[:read] > 0)
          
          write Message.encode  command: 27,
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
end
