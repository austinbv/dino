module Dino
  class Board
    attr_reader :digital_hardware, :analog_hardware, :analog_zero
    LOW, HIGH = 000, 255
    DIVIDERS = [1, 2, 4, 8, 16, 32, 64, 128]

    def initialize(io)
      @io, @digital_hardware, @analog_hardware = io, [], []
      io.add_observer(self)
      handshake
    end

    def handshake
      @analog_zero = @io.handshake
    end

    def analog_divider=(value)
      unless DIVIDERS.include? value
        puts "Analog divider must be in #{DIVIDERS.inspect}"
      else
        write Dino::Message.encode(command: 97, value: value)
      end
    end

    def heart_rate=(value)
      write Dino::Message.encode(command: 98, aux_message: value)
    end

    def start_read
      @io.read
    end

    def stop_read
      @io.close_read
    end

    def write(msg)
      @io.write(msg)
    end

    def update(pin, msg)
      (@digital_hardware + @analog_hardware).each do |part|
        part.update(msg) if convert_pin(pin) == convert_pin(part.pin)
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
      set_pin_mode(part.pin, :in, part.pullup)
      analog_listen(part.pin)
      @analog_hardware << part
    end

    def remove_analog_hardware(part)
      stop_listener(part.pin)
      @analog_hardware.delete(part)
    end

    def set_pin_mode(pin, mode, pullup=nil)
      pin, value = convert_pin(pin), mode == :out ? 0 : 1
      write Dino::Message.encode(command: 0, pin: pin, value: value)
      set_pullup(pin, pullup) if mode == :in
    end

    def set_pullup(pin, pullup)
      pin = convert_pin(pin)
      pullup ? digital_write(pin, HIGH) : digital_write(pin, LOW)
    end

    PIN_COMMANDS = {
      digital_write:   '1',
      digital_read:    '2',
      analog_write:    '3',
      analog_read:     '4',
      digital_listen:  '5',
      analog_listen:   '6',
      stop_listener:   '7',
      servo_toggle:    '8',
      servo_write:     '9'
    }

    PIN_COMMANDS.each_key do |command|
      define_method(command) do |pin, value=nil|
        write Dino::Message.encode(command: PIN_COMMANDS[command], pin: convert_pin(pin), value: value)
      end
    end

    def convert_pin(pin)
      pin.to_s.match(/\Aa/i) ? @analog_zero + pin.to_s.gsub(/\Aa/i, '').to_i : pin.to_i
    end
  end
end
