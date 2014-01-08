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
      
      attr_reader :high, :low, :components

      def after_initialize(options={})
        @high = 1
        @low = 0
        @components = []

        @state = [0,0,0,0,0,0,0,0]
        write_state
      end

      def add_component(component)
        @components << component
      end

      def remove_component(component)
        @components.delete(component)
      end

      def convert_pin(pin)
        pin = pin.to_i
      end

      def set_pin_mode(pin, mode)
        nil
      end

      def digital_write(pin, value)
        @state[pin] = value
        write_state
      end

      alias :write :digital_write

      def write_state
        byte = @state.join("").reverse.to_i(2)
        write_bytes(byte)
      end

      def write_bytes(bytes)
        bytes = [bytes] unless bytes.class == Array

        latch.low
        bytes.each do |byte|
          board.write Dino::Message.encode(command: 11, pin: data.pin, value: byte, aux_message: clock.pin)
        end
        latch.high
      end

      alias :write_byte :write_bytes
    end
  end
end
