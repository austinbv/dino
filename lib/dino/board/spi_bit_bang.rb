module Dino
  class Board
    def spi_bb_header(clock, input, output, write, read, mode, bit_order)
      # Validate clock and data pins
      raise ArgumentError, "no clock pin given" unless clock
      raise ArgumentError, "no input or output pin given. Require either or both" unless(input || output)

      # Set the other to disabled if only one given.
      input  ||= 255
      ouptut ||= 255

      # Get the generic part of the SPI header. 
      header = spi_header_generic(write, read, mode, bit_order)

      # Generic header + packed pins + empty byte = bit bang SPI bheader.
      header = header + pack(:uint8, [clock, input, output, 0])
    end

    # CMD = 21
    def spi_bb_transfer(select_pin, clock: nil, output: nil, input: nil, write: [], read: 0, frequency: nil, mode: nil, bit_order: nil)
      raise ArgumentError, "no bytes given to read or write" if (read == 0) && (write.empty?)

      header = spi_bb_header(clock, input, output, write, read, mode, bit_order)

      self.write Message.encode command: 21,
                                pin: select_pin,
                                aux_message: header + pack(:uint8, write)
    end

    # CMD = 22
    def spi_bb_listen(select_pin, clock: nil, input: nil, read: 0, frequency: nil, mode: nil, bit_order: nil)
      raise ArgumentError, 'no bytes to read. Give read: argument > 0' unless (read > 0)

      header = spi_bb_header(clock, input, nil, [], read, mode, bit_order)

      self.write Message.encode command: 22,
                                pin: select_pin,
                                aux_message: header
    end
  end
end
