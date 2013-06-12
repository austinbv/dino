module Dino
  module Components
    class ShiftRegister < Core::MultiPin
      #
      # options = {board: my_board, pins: {clock: clock_pin, latch: latch_pin, data: data_pin}
      #
      def after_initialize(options={})
        proxy  clock: Core::BaseOutput,
               latch: Core::BaseOutput,
               data:  Core::BaseOutput
      end

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
