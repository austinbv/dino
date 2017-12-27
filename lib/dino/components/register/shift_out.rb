module Dino
  module Components
    module Register
      class ShiftOut
        #
        # options = {board: my_board, pins: {clock: clock_pin, latch: latch_pin, data: data_pin}
        #
        include Setup::MultiPin
        proxy_pins  clock: Basic::DigitalOutput,
                    latch: Register::Select,
                    data:  Basic::DigitalOutput

        def after_initialize(options={})
          #
          # To use the register as a board proxy, we need to know how many
          # bytes there are and map each bit to a virtual pin.
          # Defaults to 1 byte. Ignore if writing to the register directly.
          #
          @bytes = options[:bytes] || 1

          #
          # When used as a board proxy, store the state of each register
          # pin as a 0 or 1 in an array that is (@bytes * 8) long. Zero out to start.
          #
          @state = Array.new(@bytes*8) {|i| 0}
          write_state

          #
          # When used as a board proxy, only write sate if @write_delay seconds
          # have passed since this object last got input. Better for things like SSDs
          # where many bits change in sequence, but not at exactly the same time.
          #
          @write_delay = options[:write_delay] || 0.005

          super(options)
        end

        #
        # Send one or more bytes to the register. Clock and latch toggling
        # are handled by the board, but we still must set mode in Ruby.
        #
        def write_bytes(*bytes)
          aux = bytes.flatten
          length = aux.count
          #
          # Format request by putting 3 elements before the data bytes, so we get:
          # [data pin, clock pin, unused byte, data byte 1, data byte 2...]
          #
          aux = [data.pin, clock.pin, 0].concat(aux)

          # Pack into literal format for aux msg compatbility then send.
          aux = aux.pack('C*')
          board.write Dino::Message.encode(command: 22, pin: latch.pin, value: length, aux_message: aux)
        end

        alias :write_byte :write_bytes
        alias :write :write_bytes

        #
        # Make the register act as a board for components that need only digital
        # output pins. Pass the register as a 'board' and pin numbers such that pin 0
        # is the 1st bit of the 1st byte, pin 9 is 1st bit of the 2nd byte, and so on.
        #
        include Mixins::BoardProxy
        def digital_write(pin, value)
          @state[pin] = value
          delayed_write(@state)
        end

        #
        # If acting as board, do writes in a separate thread and with small delay.
        # Lets us catch multiple changed bits, like when hosting an SSD.
        #
        include Mixins::Threaded
        def delayed_write(state)
          threaded do
            sleep @write_delay
            write_state if (state == @state)
          end
        end

        #
        # Convert bit state to array of 0-255 integers (bytes) then write normally.
        #
        def write_state
          bytes = []
          @state.each_slice(8) do |slice|
            bytes << slice.join("").to_i(2)
          end
          write_bytes(bytes)
        end
      end
    end
  end
end
