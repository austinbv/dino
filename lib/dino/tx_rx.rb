require 'celluloid'
require 'serialport'

module Dino
  class TxRx
    include Celluloid
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
      loop do
        if IO.select([io], nil, nil, 0.05)
          puts io.gets
        end
        sleep 0.001
      end
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