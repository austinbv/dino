module Dino
  module Components
    module Register
      module Output
        include Setup::Base

        def after_initialize(options={})
          super(options) if defined?(super)
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
          @state = Array.new(@bytes*8) { 0 }
          write_state

          #
          # When used as a board proxy, only write sate if @write_delay seconds
          # have passed since this object last got input. Better for things like SSDs
          # where many bits change in sequence, but not at exactly the same time.
          #
          @write_delay = options[:write_delay] || 0.005
        end

        def write
          raise 'define #write in child class based on communication method'
        end

        #
        # Make the register act as a board for components that need only digital
        # output pins. Pass the register as a 'board' and pin numbers such that pin 0
        # is the 1st bit of the 1st byte, pin 9 is 1st bit of the 2nd byte, and so on.
        #
        include Mixins::BoardProxy
        def digital_write(pin, value)
          state[pin] = value
          delayed_write(state)
        end
        
        def digital_read(pin)
          state[pin]
        end

        #
        # If acting as board, do writes in a separate thread and with small delay.
        # Lets us catch multiple changed bits, like when hosting an SSD.
        #
        include Mixins::Threaded
        def delayed_write(old_state)
          threaded do
            sleep @write_delay
            # Keep delaying if state has changed.
            write_state if (old_state == state)
          end
        end

        #
        # Convert bit state to array of 0-255 integers (bytes) then write normally.
        #
        def write_state
          bytes = []
          state.each_slice(8) do |slice|
            # Convert nil to 0 to ensure bit order is consistent.
            zeroed = slice.map { |bit| bit.to_i }.join.to_i(2)
            bytes << zeroed
          end
          write(bytes)
        end
      end
    end
  end
end
