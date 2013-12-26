module Dino
  module Components
    class ShiftRegister
      #
      # options = {board: my_board, pins: {clock: clock_pin, latch: latch_pin, data: data_pin}
      #
      include Setup::MultiPin      
      proxy_pins  clock: Basic::DigitalOutput,
                  latch: Basic::DigitalOutput,
                  data:  Basic::DigitalOutput
            
      def write(bytes)
        bytes = [bytes] unless bytes.class == Array

        latch.low
        bytes.each do |byte|
          board.write Dino::Message.encode(command: 11, pin: data.pin, value: byte, aux_message: clock.pin)
        end
        latch.high
      end
    end
  end
end
