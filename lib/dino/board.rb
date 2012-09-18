require 'observer'

module Dino
  class Board
    include Observable

    HIGH = 255
    LOW = 000

    def initialize(io)
      @io = io
      io.add_observer(self)
      send_clearing_bytes
    end

    def update(pin, msg)
      changed && notify_observers(pin, msg)
    end

    def start_read
      @io.read
    end

    def stop_read
      @io.close_read
    end

    def write(msg, opts = {})
      formatted_msg = opts.delete(:no_wrap) ? msg : "!#{msg}."
      @io.write(formatted_msg).nil?
    end

    def digital_write(pin, value)
      '/dev/tty.usbmodem1411'
      pin, value = normalize_pin(pin), normalize_value(value)
      write("01#{pin}#{value}")
    end

    def digital_read(pin)
      pin, value = normalize_pin(pin), normalize_value(0)
      write("02#{pin}#{value}")
    end

    def set_pin_mode(pin, mode)
      pin, value = normalize_pin(pin), normalize_value(mode == :out ? 1 : 0)
      write("00#{pin}#{value}")
    end

    def set_debug(on_off)
      pin, value = normalize_pin(0), normalize_value(on_off == :on ? 1 : 0)
      write("99#{pin}#{value}")
    end

    def normalize_pin(pin)
      raise Exception.new('pins can only be two digits') if pin.to_s.length > 2
      normalize(pin, 2)
    end

    def normalize_value(value)
      raise Exception.new('values are limited to three digits') if value.to_s.length > 3
      normalize(value, 3)
    end

    private

    def normalize(pin, spaces)
      pin.to_s.rjust(spaces, '0')
    end

    def send_clearing_bytes
      write('00000000', no_wrap: true)
    end
  end
end