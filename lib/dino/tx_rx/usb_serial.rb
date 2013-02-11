require 'serialport'

module Dino
  module TxRx
    class USBSerial < Base
      BAUD = 115200

      def initialize
        @first_write = true
      end

      def io
        raise BoardNotFound unless @io ||= find_arduino
        @io
      end

      def io=(device)
        @io = SerialPort.new(device, BAUD)
      end

      def gets
        IO.select([io], nil, nil, 0.05) && io.gets
      end

      def flush_read
        gets until gets == nil
      end

      def write(message)
        IO.select(nil, [io], nil)
        io.puts(message)
      end

      private

      def tty_devices
        if RUBY_PLATFORM.include?("mswin") || RUBY_PLATFORM.include?("mingw")
          ["COM1", "COM2", "COM3", "COM4"]
        else
          `ls /dev`.split("\n").grep(/usb|ACM/).map{|d| "/dev/#{d}"}
        end
      end

      def find_arduino
        tty_devices.map do |device|
          next if device.match /^cu/
          begin
            SerialPort.new(device, BAUD)
          rescue
            nil
          end
        end.compact.first
      end
    end
  end
end
