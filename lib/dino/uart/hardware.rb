module Dino
  module UART
    class Hardware
      include Behaviors::SinglePin
      include Behaviors::Callbacks

      attr_reader :index, :baud
      
      def before_initialize(options={})
        if options[:index] && (options[:index] > 0) && (options[:index] < 4)
          @index = options[:index]
        else
          raise ArgumentError, "UART index (#{options[:index]}) not given or out of range (1..3)"
        end

        # Set pin to a "virtual pin" in 251 - 253 that will match the board.
        options[:pin] = 250 + options[:index]
      end
      alias :rx_pin :pin

      def after_initialize(options={})
        initialize_buffer
        start(options[:baud] ||= 9600)
      end

      def initialize_buffer
        @buffer       = ""
        @buffer_mutex = Mutex.new
        self.add_callback(:buffer) do |data|
          @buffer_mutex.synchronize do
            @buffer = "#{@buffer}#{data}"
          end
        end
      end

      def gets
        @buffer_mutex.synchronize do
          newline = @buffer.index("\n")
          return nil unless newline
          line = @buffer[0..newline-1].chop
          @buffer = @buffer[newline+1..-1]
          return line
        end
      end

      def start(baud)
        @baud = baud
        board.uart_start(index, baud, true)
      end

      def stop()
        board.uart_stop(index)
      end

      def write(data)
        board.uart_write(index, data)
      end
    end
  end
end
