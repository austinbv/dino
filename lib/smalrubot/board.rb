module Smalrubot
  class Board
    attr_reader :digital_hardware, :analog_hardware, :analog_zero
    LOW, HIGH = 000, 255

    def initialize(io)
      @io, @digital_hardware, @analog_hardware = io, [], []
      handshake
    end

    def handshake
      @analog_zero = @io.handshake
    end

    def analog_divider=(value)
      unless [1, 2, 4, 8, 16, 32, 64, 128].include? value
        puts "Analog divider must be in 1, 2, 4, 8, 16, 32, 64, 128"
      else
        write "9700#{normalize_value(value)}"
      end
    end

    def heart_rate=(value)
      write "9800#{normalize_value(value)}"
    end

    def write(msg, opts = {})
      formatted_msg = opts.delete(:no_wrap) ? msg : "!#{msg}."
      @io.write(formatted_msg)
    end

    def read
      @io.read(1)
    end

    def set_pin_mode(pin, mode, pullup=nil)
      pin, value = normalize_pin(pin), normalize_value(mode == :out ? 0 : 1)
      write("00#{pin}#{value}")
      set_pullup(pin, pullup) if mode == :in
    end

    def set_pullup(pin, pullup)
      pullup ? digital_write(pin, HIGH) : digital_write(pin, LOW)
    end

    WRITE_COMMANDS = {
      digital_write:   '01',
      analog_write:    '03',
      servo_toggle:    '08',
      servo_write:     '09'
    }

    WRITE_COMMANDS.each_key do |command|
      define_method(command) do |pin, value=nil|
        cmd = normalize_cmd(WRITE_COMMANDS[command])
        write("#{cmd}#{normalize_pin(pin)}#{normalize_value(value)}")
      end
    end

    READ_COMMANDS = {
      digital_read:    '02',
      analog_read:     '04',
    }

    READ_COMMANDS.each_key do |command|
      define_method(command) do |pin|
        cmd = normalize_cmd(READ_COMMANDS[command])
        write("#{cmd}#{normalize_pin(pin)}#{normalize_value(0)}")
        res_pin, message = *read
        if res_pin && message
          if res_pin.to_i != pin
            raise "FATAL: request and response pins are differece: request #{pin}, response: #{res_pin}"
          end
          message.to_i
        end
      end
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
  end
end
