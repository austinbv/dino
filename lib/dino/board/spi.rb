module Dino
  class Board
    def spi_header_generic(write, read, mode, bit_order)
      # Defaults.
      mode      ||= 0
      bit_order ||= :msbfrst

      raise ArgumentError, "can't read more than 255 SPI bytes at a time" if read > 255
      raise ArgumentError, "can't write more than 255 SPI bytes at a time" if write.length > 255

      # Lowest 2 bits of settings control the SPI mode.
      settings = mode
      unless (0..3).include? settings
        raise ArgumentError, "invalid SPI mode: #{settings.inspect}. Must be 0, 1, 2, or 3"
      end

      # Bit 7 of settings toggles MSBFIRST (1) or LSBFIRST (0) for both read and write.
      settings = settings | 0b10000000 unless bit_order == :lsbfirst

      # Return generic portion of header (used by both hardware and bit bang SPI).
      pack(:uint8, [settings, read, write.length])
    end

    def spi_header(write, read, frequency, mode, bit_order)
      # Set default frequency and validate.
      frequency ||= 1000000
      unless [Integer, Float].include? frequency.class
        raise ArgumentError, "error in SPI frequency: #{frequency.inspect}"
      end

      # Get the generic part of the SPI header. 
      header = spi_header_generic(write, read, mode, bit_order)

      # Generic header + packed frequency = hardware SPI header.
      header + pack(:uint32, frequency)
    end

    # CMD = 26
    def spi_transfer(select_pin, write: [], read: 0, frequency: nil, mode: nil, bit_order: nil)
      raise ArgumentError, "no bytes given to read or write" if (read == 0) && (write.empty?)

      header = spi_header(write, read, frequency, mode, bit_order)

      self.write Message.encode command: 26,
                                pin: select_pin,
                                aux_message: header + pack(:uint8, write)
    end

    # CMD = 27
    def spi_listen(select_pin, read: 0, frequency: nil, mode: nil, bit_order: nil)
      raise ArgumentError, 'no bytes to read. Give read: argument > 0' unless (read > 0)

      header = spi_header([], read, frequency, mode, bit_order)
      
      self.write Message.encode command: 27,
                                pin: select_pin,
                                aux_message: header
    end

    # CMD = 28
    def spi_stop(select_pin)
      self.write Message.encode command: 28, pin: select_pin
    end
  end
end
