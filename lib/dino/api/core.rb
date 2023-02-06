module Dino
  module API
    module Core
      include Helper

      DIVIDERS = [1, 2, 4, 8, 16, 32, 64, 128]

      # CMD = 0
      def set_pin_mode(pin, mode)
        pin, value = convert_pin(pin), mode == :out ? 0 : 1
        write Message.encode command: 0,
                             pin: convert_pin(pin),
                             value: value
      end

      # CMD = 1
      def digital_write(pin,value)
        write Message.encode command: 1, pin: convert_pin(pin), value: value
      end

      # CMD = 2
      def digital_read(pin)
        write Message.encode command: 2, pin: convert_pin(pin)
      end

      # CMD = 3
      def analog_write(pin,value)
        write Message.encode command: 3, pin: convert_pin(pin), value: value
      end

      # CMD = 4
      def analog_read(pin)
        write Message.encode command: 4, pin: convert_pin(pin)
      end

      def set_pullup(pin, pullup)
        pin = convert_pin(pin)
        pullup ? digital_write(pin, @high) : digital_write(pin, @low)
      end

      # CMD = 5
      def set_listener(pin, state=:off, options={})
        mode    = options[:mode]    || :digital
        divider = options[:divider] || 16

        unless [:digital, :analog].include? mode
          raise "Mode must be either digital or analog"
        end
        unless DIVIDERS.include? divider
          raise "Listener divider must be in #{DIVIDERS.inspect}"
        end

        exponent = Math.log2(divider).to_i
        aux = pack :uint8, [mode == :analog ? 1 : 0, exponent]

        write Message.encode command: 5,
                             pin: convert_pin(pin),
                             value: (state == :on ? 1 : 0),
                             aux_message: aux
      end

      # Convenience methods by wrapping set_listener with old defaults.
      def digital_listen(pin, divider=4)
        set_listener(pin, :on, mode: :digital, divider: divider)
      end

      def analog_listen(pin, divider=16)
        set_listener(pin, :on, mode: :analog, divider: divider)
      end

      def stop_listener(pin)
        set_listener(pin, :off)
      end

      def pulse_read(pin, options={})
        # Hold the input pin high or low (give as values) before reading
        reset = options[:reset] || false
        
        # How long to reset the pin for in ms
        reset_time = options[:reset_time] || 0
        
        # Maximum number of pulses to capture
        pulse_limit = options[:pulse_limit] || 100
        
        # A pulse of this length will end the read
        timeout = options[:timeout] || 200
        
        raise ArgumentError("reset time must be betwen 0 and 65535 ms")if reset_time > 0xFFFF
        raise ArgumentError("timeout must be betwen 0 and 65535 ms")if timeout > 0xFFFF
        raise ArgumentError("pulse limit must be betwen 0 and 255")if pulse_limit > 0xFF

        settings = reset ? 1 : 0
        settings = settings | 0b10 if (reset && reset != low)

        aux = pack :uint16, [reset_time, timeout]
        aux << pack(:uint8, pulse_limit)

        write Message.encode command: 11,
                             pin: convert_pin(pin),
                             value: settings,
                             aux_message: aux
      end
    end
  end
end
