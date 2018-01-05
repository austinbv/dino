module Dino
  module Components
    module Register
      class ShiftOut
        include Output
        #
        # Model registers that use the arduino shift functions as multi-pin
        # components, specifying clock, data and latch pins.
        #
        # options = {board: my_board, pins: {clock: clock_pin, latch: latch_pin, data: data_pin}
        #
        include Setup::MultiPin
        proxy_pins  clock: Basic::DigitalOutput,
                    data:  Basic::DigitalOutput,
                    latch: Register::Select


        #
        # Write using the native shiftOut function of the Arduino library.
        #
        def write(*bytes)
          aux = bytes.flatten
          length = aux.count

          # Prepend parameters we need to send in the aux message then pack and send.
          aux = [data.pin, clock.pin, 0].concat(aux).pack('C*')
          board.write Dino::Message.encode(command: 21, pin: latch.pin, value: length, aux_message: aux)
        end
      end
    end
  end
end
