module Dino
  module SPI
    class OutputRegister < BaseRegister

      def before_initialize(options={})
        super(options)
        #
        # When used as a board proxy, only write sate if @write_delay seconds
        # have passed since this object last got input. Better for things like SSDs
        # where many bits change in sequence, but not at exactly the same time.
        #
        @buffer_writes = true
        @buffer_writes = false if options[:buffer_writes] == false
        @write_delay = options[:write_delay] || 0.001
      end
      
      def after_initialize(options={})
        write
      end

      #
      # Overrides Peripheral#write to always write @state.
      # Convert bit state to array of 0-255 integers (bytes) first.
      #
      def write
        bytes = []
        @state.each_slice(8) do |slice|
          # Convert nils in the slice to zero.
          zeroed = slice.map { |bit| bit.to_i }
          
          # Each slice is 8 bits of a byte, with the lowest on the left.
          # Reverse to reading order (lowest right) then join into string, and convert to integer.
          byte = zeroed.reverse.join.to_i(2)
          
          # Pack bytes in reverse order.
          bytes.unshift byte
        end
        super(bytes)
      end

      #
      # BoardProxy interface
      #
      def digital_write(pin, value)
        state[pin] = value  # Might not be atomic?
        @buffer_writes ? write_buffered(state) : write
      end
      
      def digital_read(pin)
        state[pin]
      end

      #
      # If acting as board, do writes in a separate thread and with small delay.
      # Lets us catch multiple changed bits, like when hosting an SSD.
      #
      include Behaviors::Threaded
      def write_buffered(old_state)
        threaded do
          sleep @write_delay
          # Keep delaying if state has changed.
          write if (old_state == state)
        end
      end
    end
  end
end
