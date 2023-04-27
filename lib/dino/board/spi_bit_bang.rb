module Dino
  class Board
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
  end
end
