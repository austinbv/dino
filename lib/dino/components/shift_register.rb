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

      def after_initialize(options={})
        @bytes = options[:bytes] || 1
        @state = Array.new(@bytes*8) {|i| 0}
        write_state
        super
      end

      def write_state
        bytes = []
        @state.each_slice(8) do |slice|
          bytes << slice.join("").reverse.to_i(2)
        end
        write_bytes(bytes)
      end

      def write_bytes(bytes)
        latch.low
        bytes.each do |byte|
          board.write Dino::Message.encode(command: 11, pin: data.pin, value: byte, aux_message: clock.pin)
        end
        latch.high
      end

      alias :write_byte :write_bytes

      #
      # Make the shift register behave like a board.
      # We can use each output pin on it individually for digital out components.
      # To set up component, use the register object as the 'board', and the corresponding pin numbers.
      #
      include Mixins::BoardProxy
      include Mixins::Threaded

      def digital_write(pin, value)
        @last_input = Time.now
        @state[pin] = value
        start_write
      end

      alias :write :digital_write

      #
      # Wait until we have not had a digital_write for 1ms before writing to the board.
      # Reduces the amount of wrting required for things like SSDs that change many bits in sequence.
      #
      def start_write
        return if @thread
        @last_output = Time.now
        threaded_loop do
          if ((Time.now - @last_input) > 0.001) && (@last_input > @last_output)
            write_state
            @last_output = Time.now
          end
        end
      end
    end
  end
end
