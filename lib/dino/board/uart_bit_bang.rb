module Dino
  class Board
    # CMD = 12
    def uart_bb_start(tx, rx, baud, listening=true)
      config  = 0b01000000
      config |= 0b10000000 if listening

      self.write Message.encode command:      12,
                                pin:          tx,
                                value:        rx,
                                aux_message:  pack(:uint32, baud) + pack(:uint8, config)
    end

    # CMD = 12
    def uart_bb_stop
      config = 0b00000000
      self.write Message.encode command:      12,
                                aux_message:  pack(:uint32, [0]) + pack(:uint8, config)
    end

    # CMD = 13
    def uart_bb_write(data)
      if data.class == Array
        data = pack(:uint8, data)
      elsif data.class == String
      else
        raise ArgumentError, "data to write to UART should be Array of bytes or String. Given: #{data.inspect}"
      end

      self.write Message.encode(command: 13, value: data.length, aux_message: data)
    end
  end
end
