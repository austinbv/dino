require 'celluloid'
require 'serialport'

module Dino
  class TxRx
    include Celluloid
    BAUD = 115200

    def arduino
      @arduino ||= tty_devices.map do |device|
        next if device.match /^cu/
        begin
          SerialPort.new(device, BAUD)
        rescue
          nil
        end
      end.compact.first
    end

    def arduino=(device)
      @arduino = SerialPort.new(device, BAUD)
    end

    def read
      message, started = [], false

      loop do
        input = @arduino.getc

        if input == '!' || started
          message << input
          started = true
        end

        if input == '.'
          started = false
          puts input
        end
      end
    end

    def puts(message)
      @arduino.puts(message)
    end

    def serial_messages
    end

    private

    def tty_devices
      exec('ls /dev | grep usb').split /\n/
    end
  end
end