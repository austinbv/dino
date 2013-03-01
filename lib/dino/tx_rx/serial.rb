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

      private

      def connect
        tty_devices.each { |device| return SerialPort.new(device, @baud) rescue nil }
        raise BoardNotFound
      end

      def tty_devices
        return [@device] if @device
        return (1..9).map { |n| "COM#{n}" } if RUBY_PLATFORM.match /mswin|mingw/i
        `ls /dev`.split("\n").grep(/usb|ACM/).map{ |d| "/dev/#{d}" }
      end
    end
  end
end
