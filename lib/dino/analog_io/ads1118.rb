module Dino
  module AnalogIO
    class ADS1118
      include SPI::Peripheral
      include Behaviors::Reader
      include Behaviors::Threaded

      PGA_SETTINGS = [  # Bitmask   Full scale voltage
        0.0001875,      # 0b000     6.144 V
        0.000125,       # 0b001     4.095 V
        0.0000625,      # 0b010     2.048 V (default)
        0.00003125,     # 0b011     1.024 V
        0.000015625,    # 0b100     0.512 V
        0.0000078125,   # 0b101     0.256 V
        0.0000078125,   # 0b110     0.256 V
        0.0000078125,   # 0b111     0.256 V
      ]
      PGA_RANGE = (0..7).to_a

      # Sample rate bitmask maps to sample time in seconds.
      SAMPLE_TIMES = [  # Bitmask
        0.125,          # 0b000
        0.0625,         # 0b001
        0.03125,        # 0b010
        0.015625,       # 0b011
        0.0078125,      # 0b100 (default)
        0.004,          # 0b101
        0.002105263,    # 0b110
        0.00116279,     # 0b111
      ]
      SAMPLE_RATE_RANGE = (0..7).to_a

      # Wait times need to be slightly longer than the actual sample times.
      WAIT_TIMES = SAMPLE_TIMES.map { |time| time + 0.0005 }

      # Mux bits map to array of form [positive input, negative input].
      MUX_SETTINGS = {
        0b000 => [0, 1],
        0b001 => [0, 3],
        0b010 => [1, 3],
        0b011 => [2, 3],
        0b100 => [0, nil],
        0b101 => [1, nil],
        0b110 => [2, nil],
        0b111 => [3, nil],
      }

      # Config register values on startup.
      CONFIG_DEFAULT = [0x05, 0x8B]

      # Base config bytes to mask settings into. Not same as default.
      BASE_MSB = 0b10000001
      BASE_LSB = 0b00001011

      def after_initialize(options={})
        super(options)

        # SPI mode 1 recommended.
        @spi_mode = options[:spi_mode] || 1

        # Mutex and variables for BoardProxy behavior.
        @mutex        = Mutex.new
        @active_pin   = nil
        @active_gain  = nil

        # Set register bytes to default and write to device.
        @config_register = CONFIG_DEFAULT.dup
        transfer(write: @config_register)

        # Enable BoardProxy callbacks.
        enable_proxy
      end

      def _read(config)
        # Write config register to start reading.
        transfer(write: config)
        
        # Sleep the right amount of time for conversion, based on sample rate bits.
        sleep WAIT_TIMES[config[1] >> 5]

        # Read the result, triggering callbacks.
        transfer(read: 2)
      end

      # Pack the 2 bytes back into a string, then unpack as big-endian int16.
      def pre_callback_filter(message)
        bytes = message.split(",").map { |b| b.to_i }
        bytes.pack("C*").unpack("s>")[0]
      end

      def _temperature_read
        # Wrap in mutex to not interfere with other reads.
        @mutex.synchronize do
          _read([0b10000001, 0b10011011])
        end
      end

      def temperature_read(&block)
        reading = read_using -> { _temperature_read }
        
        # Temperature is shifted 2 bits left, and is 0.03125 degrees C per bit.
        temperature = (reading / 4) * 0.03125

        block.call(temperature) if block_given?
        return temperature
      end

      #
      # BoardProxy behavior so AnalogIO classes can use this as a Board.
      #
      include Behaviors::BoardProxy

      # Mimic Board#update, but inside a callback, wrapped by #update.
      def enable_proxy
        self.add_callback(:board_proxy) do |value|
          components.each do |component|
            if @active_pin == component.pin
              component.volts_per_bit = PGA_SETTINGS[@active_gain]
              component.update(value) 
            end
          end
        end
      end

      def analog_read(pin, negative_pin=nil, gain=nil, sample_rate=nil)
        # Wrap in mutex so calls and callbacks are atomic.
        @mutex.synchronize do
          # Default gain and sample rate.
          gain        ||= 0b010
          sample_rate ||= 0b100

          # Set these for callbacks.
          @active_pin   = pin
          @active_gain  = gain

          # Set gain in upper config register.
          raise ArgumentError "wrong gain: #{gain.inspect} given for ADS1118" unless PGA_RANGE.include?(gain)
          @config_register[0] = BASE_MSB | (gain << 1)

          # Set mux bits in upper config register.
          mux_bits = pins_to_mux_bits(pin, negative_pin)
          @config_register[0] = @config_register[0] | (mux_bits << 4)

          # Set sample rate in lower config_register.
          raise ArgumentError "wrong sample_rate: #{sample_rate.inspect} given for ADS1118" unless SAMPLE_RATE_RANGE.include?(gain)
          @config_register[1] = BASE_LSB | (sample_rate << 5)

          read(@config_register)
        end
      end

      def pins_to_mux_bits(pin, negative_pin)
        # Pin 1 is negative input. Only pin 0 can be read.
        if negative_pin == 1
          raise ArgumentError, "given pin: #{pin.inspect} cannot be used when pin 1 is negative input, only 0" unless pin == 0
          return 0b000
        end

        # Pin 3 is negative input. Pins 0..2 can be read.
        if negative_pin == 3
          raise ArgumentError, "given pin: #{pin.inspect} cannot be used when pin 3 is negative input, only 0..2" unless [0,1,2].include? pin
          return 0b001 + pin
        end

        # No negative input. Any pin from 0 to 3 can be read.
        unless negative_pin
          raise ArgumentError, "given pin: #{pin.inspect} is out of range 0..3" unless [0,1,2,3].include? pin
          return (0b100 + pin)
        end

        raise ArgumentError, "only pins 1 and 3 can be used as negative input"
      end

      def analog_listen(pin, divider=nil)
        raise StandardError, "ADS1118 does not implement #listen for subcomponents. Use #read or #poll instead"
      end

      def stop_listener(pin)
      end
    end
  end
end
