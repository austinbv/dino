module Dino
  module Components
    class ShiftRegister < Core::Base
      # options = {board: my_board, pins: {latch: latch_pin, clock: clock_pin, data: data_pin}
      def after_initialize(options={})
        raise 'missing pins[:latch] pin' unless self.pins[:latch]
        raise 'missing pins[:clock] pin' unless self.pins[:clock]
        raise 'missing pins[:data] pin' unless self.pins[:data]

        pins.each_value do |pin|
          set_pin_mode(pin, :out)
          digital_write(pin, Board::LOW)
        end
      end

      def latch_off
        digital_write(pins[:latch], Board::LOW)
      end

      def latch_on
        digital_write(pins[:latch], Board::HIGH)
      end

      def write(bytes)
        bytes = [bytes] unless bytes.class == Array
        data_pin = board.convert_pin(pins[:data])
        clock_pin = board.convert_pin(pins[:clock])

        latch_off
        bytes.each do |byte|
          board.write Dino::Message.encode( command: 11, pin: data_pin, value: byte, aux_message: clock_pin)
        end
        latch_on
      end
    end
  end
end
