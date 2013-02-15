require 'timeout'

module Dino
  class Board
    attr_reader :digital_hardware, :analog_hardware, :analog_zero
    LOW, HIGH = 000, 255

    def initialize(io)
      @io, @digital_hardware, @analog_hardware = io, [], []
      io.add_observer(self)
      handshake
    end

    def update(pin, msg)
      (@digital_hardware + @analog_hardware).each do |part|
        part.update(msg) if normalize_pin(pin) == normalize_pin(part.pin)
      end
    end

    def add_digital_hardware(part)
      set_pin_mode(part.pin, :in, part.pullup)
      digital_listen(part.pin)
      @digital_hardware << part
    end

    def remove_digital_hardware(part)
      stop_listener(part.pin)
      @digital_hardware.delete(part)
    end

    def add_analog_hardware(part)
      set_pin_mode(part.pin, :in)
      analog_listen(part.pin)
      @analog_hardware << part
    end

    def remove_analog_hardware(part)
      stop_listener(part.pin)
      @analog_hardware.delete(part)
    end

    def start_read
      @io.read
    end

    def stop_read
      @io.close_read
    end

    def write(msg, opts = {})
      formatted_msg = opts.delete(:no_wrap) ? msg : "!#{msg}."
      @io.write(formatted_msg)
    end

    def set_pin_mode(pin, mode, pullup=nil)
      pin, value = normalize_pin(pin), normalize_value(mode == :out ? 0 : 1)
      write("00#{pin}#{value}")
      digital_write(pin, 1) if (pullup && mode != :out)
    end

    COMMANDS = {
      digital_write:   01,
      digital_read:    02,
      analog_write:    03,
      analog_read:     04,
      digital_listen:  05,
      analog_listen:   06,
      stop_listener:   07,
    }

    COMMANDS.each_key do |command|
      define_method(command) do |pin, value=nil|
        cmd = normalize_cmd(COMMANDS[command])
        write "#{cmd}#{normalize_pin(pin)}#{normalize_value(value)}"
      end
    end

    def reset
      write("!9000000.", no_wrap: true)
    end

    def set_debug(on_off)
      pin, value = normalize_pin(0), normalize_value(on_off == :on ? 1 : 0)
      write("99#{pin}#{value}")
    end

    def normalize_pin(pin)
      if pin.to_s.match /\Aa/i
        int_pin = @analog_zero + pin.to_s.gsub(/\Aa/i, '').to_i
      else
        int_pin = pin
      end
      raise Exception.new('pin number must be in 0-99') if int_pin.to_i > 99
      return normalize(int_pin, 2)
    end

    def normalize_cmd(cmd)
      raise Exception.new('commands can only be two digits') if cmd.to_s.length > 2
      normalize(cmd, 2)
    end

    def normalize_value(value)
      raise Exception.new('values are limited to three digits') if value.to_s.length > 3
      normalize(value, 3)
    end

    private

    def normalize(pin, spaces)
      pin.to_s.rjust(spaces, '0')
    end

    def handshake
      50.times do
        begin
          reset
          Timeout::timeout(0.1) do
            line = @io.gets.to_s.chop
            if line.match /ACK/
              @analog_zero = line.split(/:/)[1].to_i
              return @io.flush_read 
            end
          end
        rescue
          nil
        end
      end
      raise BoardNotFound
    end
  end
end