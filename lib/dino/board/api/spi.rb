module Dino
  module Board
    module API
      module SPI
        include Helper

        def spi_header(options)
          settings, options = spi_validate(options)
          header = pack :uint8, [settings, options[:read], options[:write].length]

          options[:frequency]  ||= 1000000
          unless [Integer, Float].include? options[:frequency].class
            raise ArgumentError, "error in SPI frequency: #{options[:frequency]}"
          end
          
          header = header + pack(:uint32, options[:frequency])

          [header, options]
        end

        # CMD = 26
        def spi_transfer(select_pin, options={})
          header, options = spi_header(options)
          
          if (options[:read] == 0) && (options[:write].empty?)
            raise ArgumentError, "no bytes given to read or write"
          end
          
          write Message.encode  command: 26,
                                pin: select_pin,
                                aux_message: header + pack(:uint8, options[:write])
        end

        # CMD = 27
        def spi_listen(select_pin, options={})
          header, options = spi_header(options)
          
          raise ArgumentError, 'no bytes to read' unless (options[:read] > 0)
          
          write Message.encode  command: 27,
                                pin: select_pin,
                                aux_message: header
        end

        # CMD = 28
        def spi_stop(select_pin)
          write Message.encode command: 28, pin: select_pin
        end
      end
    end
  end
end
