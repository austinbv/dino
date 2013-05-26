require 'serialport'

module Dino
  module TxRx
    class Serial < Base
      BAUD = 115200

      def initialize(options={})
        @device = options[:device]
        @baud = options[:baud] || BAUD
        @first_write = true
      end

      def io
        @io ||= connect
      end

      def handshake
        if on_windows?
          io; sleep 3
        end
        
        super
      end

      private

      def connect
        tty_devices.each { |device| return SerialPort.new(device, @baud) rescue nil }
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
    end
  end
end
