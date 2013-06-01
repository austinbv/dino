module Dino
  module Components
    class ShiftRegister < BaseComponent
      # options = {board: my_board, pins: {latch: latch_pin, clock: clock_pin, data: data_pin}
      def after_initialize(options={})
        raise 'missing pins[:latch] pin' unless self.pins[:latch]
        raise 'missing pins[:clock] pin' unless self.pins[:clock]
        raise 'missing pins[:data] pin' unless self.pins[:data]

        pins.each do |pin|
          set_pin_mode(pin, :out)
          analog_write(pin, Board::LOW)
        end
      end

      def latch_off
        digital_write(pins[:latch], Board::LOW)
      end

      def latch_on
        digital_write(pins[:latch], Board::HIGH)
      end

      def write(byte)
        latch_off
        board.write(Dino::Message.encode command: 11, pin: convert_pin(pins[:data]), value: byte, aux_message: convert_pin(pins[:clock])})
        latch_on
      end
    end
  end
end
