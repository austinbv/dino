module Dino
  module Connection
    class BoardUART < Base
      BAUD = 115200

      def initialize(uart, options={})
        @uart = uart
        @uart.start(options[:baud] || BAUD)
      end

      def baud
        @uart.baud
      end

      def flush_read
        @uart.flush
      end

      def to_s
        "#{@uart} @ #{@uart.baud} baud"
      end

      def _write(message)
        io.write(message)
      end

      def _read
        io.gets
      end

      def connect
        @uart
      end
    end
  end
end
