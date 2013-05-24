require 'serialport'
require 'observer'

module Dino
  module TxRx
    class USBSerial
      include Observable

      BAUD = 115200

      def initialize(device = nil)
        @device = device
        @first_write = true
      end

      def io
        raise BoardNotFound unless @io ||= find_arduino
        @io
      end

      def io=(device)
        @io = SerialPort.new(device, BAUD)
      end

      def read
        @thread ||= Thread.new do
          loop do
            if IO.select([io], nil, nil, 0.005)
              pin, message = *io.gets.chop.split(/::/)
              pin && message && changed && notify_observers(pin, message)
            end
            sleep 0.004
          end
        end
      end

      def close_read
        return nil if @thread.nil?
        Thread.kill(@thread)
        @thread = nil
      end

      def write(message)
        IO.select(nil, [io], nil)
        io.puts(message)
      end

      private

      def tty_devices
        return [@device] if @device
        if RUBY_PLATFORM.include?("mswin") || RUBY_PLATFORM.include?("mingw")
          com_ports = []
          1.upto(9) { |n| com_ports << "COM#{n}" }
          com_ports
        else
          `ls /dev`.split("\n").grep(/usb|ACM/i).map{|d| "/dev/#{d}"}
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
