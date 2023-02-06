require 'rubyserial'

module Dino
  module TxRx
    class Serial < Base
      BAUD = 115200

      def initialize(options={})
        @device = options[:device]
        @baud = options[:baud] || BAUD
      end

      def to_s
        "#{@device} @ #{@baud} baud"
      end

      def write(message)
        io.write(message)
      end

      def read
        buff, escaped = "", false
        loop do
          char = io.read(1)
          if ["\n", "\\"].include? char
            if escaped
              buff << char
              escaped = false
            elsif (char == "\n")
              return buff
            elsif (char == "\\")
              escaped = true
            end
          else
            escaped = false
            buff << char
          end
          return nil if (buff.empty? && !escaped)
        end
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
