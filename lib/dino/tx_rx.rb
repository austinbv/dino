require 'serialport'

module Dino
  class TxRx
    BAUD = 115200

    def io
      @io ||= tty_devices.map do |device|
        next if device.match /^cu/
        begin
          SerialPort.new("/dev/#{device}", BAUD)
        rescue
          nil
        end
      end.compact.first
    end

    def io=(device)
      @io = SerialPort.new(device, BAUD)
    end

    def read
      @thread ||= Thread.new do
        loop do
          if IO.select([io], nil, nil, 0.05)
            puts io.gets
          end
          sleep 0.005
        end
      end
    end

    def close_read
      Thread.kill(@thread)
      @thread = nil
    end

    def write(message)
      IO.select(nil, [io], nil, 0.05)
      io.puts(message)
    end

    private

    def tty_devices
      `ls /dev | grep usb`.split(/\n/)
    end
  end
end