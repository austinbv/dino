require 'rubyserial'

module Dino
  module Connection
    class Serial < Base
      BAUD = 115200

      def initialize(options={})
        @device = options[:device]
        @baud = options[:baud] || BAUD
        @rx_buffer = ""
        @rx_line = ""
        @rx_escaped = false
      end

      def to_s
        "#{@device} @ #{@baud} baud"
      end

      def _write(message)
        io.write(message)
      end

      def _read
        # A native USB serial packet can be up to 64 bytes.
        @rx_buffer << io.read(64) if @rx_buffer.empty?

        while @rx_buffer.length > 0
          # Take a single character off the RX buffer.
          char = @rx_buffer[0]
          @rx_buffer = @rx_buffer[1..-1]

          if @rx_escaped
            @rx_line << char
            @rx_escaped = false
          else
            if (char == "\n")
              line = @rx_line
              @rx_line = ""
              return line
            elsif (char == "\\")
              @rx_escaped = true
            else
              @rx_line << char
              @rx_escaped = false
            end
          end
        end

        # Return nil if line wasn't returned and entire buffer parsed.
        return nil
      end

    private

      def connect
        tty_devices.each do |device|
          begin
            @device = device
            print "Trying serial device: #{self.to_s}... "
            connection = ::Serial.new(@device, @baud)
            puts "Connected"
            return connection
          rescue RubySerial::Error => error
            handle_error(error); next
          end
        end
        raise SerialConnectError, "Could not connect to a serial device."
      end

      def handle_error(error)
        if error.message == "EBUSY"
          puts "Device Busy! (EBUSY)"
        else
          puts "RubySerial Error (#{error.message})"
        end
      end

      def tty_devices
        return [@device] if @device
        return (1..256).map { |n| "COM#{n}" } if on_windows?
        `ls /dev`.split("\n").grep(/usb|ACM/i).map{ |d| "/dev/#{d}" }
      end

      def on_windows?
        RUBY_PLATFORM.match(/mswin|mingw/i)
      end
    end
  end
end
