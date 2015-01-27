module Smalrubot
  class Board
    attr_reader :analog_zero
    LOW, HIGH = 000, 255

    def initialize(io)
      @io = io
      @mutex = Mutex.new
      handshake
    end

    def handshake
      @mutex.synchronize do
        @analog_zero = @io.handshake
      end
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
      servo_write:     '09',

      set_dc_motor_calibration: '20',
      init_dc_motor_port: '22',
      init_sensor_port: '25',

      dc_motor_power: '42',
      dc_motor_control: '43',
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

      get_touch_sensor_value: '61',
      get_light_sensor_value: '62',
      get_ir_photoreflector_value: '64',
    }

    READ_COMMANDS.each_key do |command|
      define_method(command) do |pin|
        cmd = normalize_cmd(READ_COMMANDS[command])
        @mutex.synchronize do
          req_pin = normalize_pin(pin)
          write("#{cmd}#{req_pin}#{normalize_value(0)}")
          loop do
            res_pin, message = *read
            if res_pin && message
              if res_pin == req_pin
                return message.to_i
              else
                Smalrubot.debug_log('WARN: detected noise!')
              end
            else
              return nil
            end
          end
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
