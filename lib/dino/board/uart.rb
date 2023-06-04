module Dino
  class Board
    UART_BAUD_RATES = [
      300, 600, 750, 1200, 2400, 4800, 9600, 19200, 31250, 38400, 57600, 74880, 115200, 230400
    ]

    # CMD = 14
    def uart_start(index, baud, listening=true)
      raise ArgumentError, "given UART: #{index} out of range. Only 1..3 supported" if (index < 1 || index > 3)
      unless UART_BAUD_RATES.include?(baud)
        raise ArgumentError, "given baud rate: #{baud} not supported. Must be in #{UART_BAUD_RATES.inspect}"
      end

      config  = index | 0b01000000
      config |= 0b10000000 if listening

      self.write Message.encode command:     14,
                                pin:         config,
                                aux_message: pack(:uint32, baud)
    end

    # CMD = 14
    def uart_stop(index)
      raise ArgumentError, "given UART: #{index} out of range. Only 1..3 supported" if (index < 1 || index > 3)
      self.write Message.encode(command: 14, pin: index)
    end

    # CMD = 15
    def uart_write(index, data)
      raise ArgumentError, "given UART: #{index} out of range. Only 1..3 supported" if (index < 1 || index > 3)

      if data.class == Array
        data = pack(:uint8, data)
      elsif data.class == String
      else
        raise ArgumentError, "data to write to UART should be Array of bytes or String. Given: #{data.inspect}"
      end

      self.write Message.encode(command: 15, pin: index, value: data.length, aux_message: data)
    end
  end
end
