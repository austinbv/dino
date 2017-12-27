module Dino
  module Components
    module Register
      class ShiftOut
        include Output
        #
        # options = {board: my_board, pins: {clock: clock_pin, latch: latch_pin, data: data_pin}
        #
        include Setup::MultiPin
        proxy_pins  clock: Basic::DigitalOutput,
                    latch: Register::Select,
                    data:  Basic::DigitalOutput

        #
        # Write using the native shiftOut function of the Arduino library.
        #
        def write(*bytes)
          aux = bytes.flatten
          length = aux.count

          # Prepend parameters we need to send in the aux message then pack and send.
          aux = [data.pin, clock.pin, 0].concat(aux).pack('C*')
          board.write Dino::Message.encode(command: 22, pin: latch.pin, value: length, aux_message: aux)
        end
      end
    end
  end
end
