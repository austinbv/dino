module Dino
  class Board
    attr_reader :high, :low, :input_hardware, :analog_zero, :dac_zero
    DIVIDERS = [1, 2, 4, 8, 16, 32, 64, 128]

    def initialize(io, options={})
      @bits = options[:bits] || 8
      @io, @input_hardware = io, []
      io.add_observer(self)

      @analog_zero, @dac_zero = @io.handshake.to_s.split(",").map { |pin| pin.to_i }
      define_logic
    end

    def define_logic
      @low      = 0
      @high     = (2 ** @bits) - 1
      self.analog_resolution = @bits
    end

    def analog_resolution=(value)
      write Dino::Message.encode(command: 96, value: value)
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
      @input_hardware.each do |part|
        part.update(msg) if convert_pin(pin) == convert_pin(part.pin)
      end
    end

    def add_input_hardware(part)
      start_read
      @input_hardware << part
      set_pin_mode(part.pin, :in, part.pullup)
    end

    def remove_input_hardware(part)
      stop_listener(part.pin)
      @input_hardware.delete(part)
    end

    def set_pin_mode(pin, mode, pullup=nil)
      pin, value = convert_pin(pin), mode == :out ? 0 : 1
      write Dino::Message.encode(command: 0, pin: pin, value: value)
      set_pullup(pin, pullup) if mode == :in
    end

    def set_pullup(pin, pullup)
      pin = convert_pin(pin)
      pullup ? digital_write(pin, @high) : digital_write(pin, @low)
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
      servo_write:     '9',
      dht_read:        '13',
      ultrasonic_read: '14'
    }

    PIN_COMMANDS.each_key do |command|
      define_method(command) do |pin, value=nil|
        write Dino::Message.encode(command: PIN_COMMANDS[command], pin: convert_pin(pin), value: value)
      end
    end

    DIGITAL_REGEX = /\A\d+\z/i
    ANALOG_REGEX = /\A(a)\d+\z/i
    DAC_REGEX = /\A(dac)\d+\z/i

    def convert_pin(pin)
      pin = pin.to_s

      return pin.to_i             if pin.match(DIGITAL_REGEX)
      return analog_pin_to_i(pin) if pin.match(ANALOG_REGEX)
      return dac_pin_to_i(pin)    if pin.match(DAC_REGEX)

      nil
    end

    def analog_pin_to_i(pin)
      @analog_zero + pin.gsub(/\Aa/i, '').to_i
    end

    def dac_pin_to_i(pin)
      @dac_zero + pin.gsub(/\Aa/i, '').to_i
    end
  end
end
