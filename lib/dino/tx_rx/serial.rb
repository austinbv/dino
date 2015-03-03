require 'rubyserial'

module Dino
  module TxRx
    class Serial < Base
      BAUD = 115200

      def initialize(options={})
        @device = options[:device]
        @baud = options[:baud] || BAUD
      end

      def write(message)
        io.write(message)
      end

    private

      def connect
        tty_devices.each { |device| return ::Serial.new(device, @baud) rescue nil }
        raise BoardNotFound
      end

      def tty_devices
        return [@device] if @device
        return (1..256).map { |n| "COM#{n}" } if on_windows?
        `ls /dev`.split("\n").grep(/usb|ACM/i).map{ |d| "/dev/#{d}" }
      end

      def on_windows?
        RUBY_PLATFORM.match /mswin|mingw/i
      end

      def gets(timeout=0)
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
            buff << char
          end
          return nil if (buff.empty? && !escaped)
        end
      end
    end
  end
end
