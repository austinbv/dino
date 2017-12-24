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
        #
        # Before the register is used as a board proxy, we need to know how many
        # bytes there are to map the register pins to virtual pins.
        # Defaults to 1 byte. Ignore if writing to the register directly.
        #
        @bytes = options[:bytes] || 1

        #
        # When used as a board proxy, store the state of each register
        # output pins as a 0 or 1 in an array that is (@bytes * 8) long.
        #
        @state = Array.new(@bytes*8) {|i| 0}
        write_state

        #
        # When used as a board proxy, only write sate if @write_delay seconds
        # has passed since last input. Looks better for things like SSDs
        # where many bits may change in sequence, but not exactly the same time.
        #
        @write_delay = options[:write_delay] || 0.005

        super
      end

      #
      # Send a single byte per message as text, so 255 as 3 bytes, not 1.
      # Use this when writing values directly to the register.
      #
      def write_bytes(*bytes)

        latch.low
        bytes.flatten.each do |byte|
          board.write Dino::Message.encode(command: 11, pin: data.pin, value: byte, aux_message: clock.pin)
        end
        latch.high
      end

      alias :write_byte :write_bytes
      alias :write :write_bytes

      #
      # Make the shift register act as a board for components that just need
      # digital output pins. To initialize a component, pass the register as a
      # 'board' and pin numbers such that pin 0 is the 1st bit of the
      # 1st regiser byte, pin 9 is the first bit of the second byte, and so on.
      #
      include Mixins::BoardProxy
      def digital_write(pin, value)
        @state[pin] = value
        delayed_write(@state)
      end

      #
      # Do writes in a separate thread and with a small delay.
      # Lets us catch multiple changed bits, like with an SSD.
      #
      include Mixins::Threaded
      def delayed_write(state)
        threaded do
          sleep @write_delay
          write_state if (state == @state)
        end
      end

      #
      # Convert state into array of 0-255 integers (each byte), then write normally.
      #
      def write_state
        puts "wrote state"
        bytes = []
        @state.each_slice(8) do |slice|
          bytes << slice.join("").reverse.to_i(2)
        end
        write_bytes(bytes)
      end
    end
  end
end
