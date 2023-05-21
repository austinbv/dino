module Dino
  module AnalogIO
    class ADS1118
      include SPI::Peripheral
      include Behaviors::Reader
      include Behaviors::Threaded

      PGA_SETTINGS = {          # Full scale voltages
        0b000 => 0.0001875,     # 6.144 V
        0b001 => 0.000125,      # 4.095 V
        0b010 => 0.0000625,     # 2.048 V (default)
        0b011 => 0.00003125,    # 1.024 V
        0b100 => 0.000015625,   # 0.512 V
        0b101 => 0.0000078125,  # 0.256 V
        0b110 => 0.0000078125,  # 0.256 V
        0b111 => 0.0000078125,  # 0.256 V
      }

      MUX_SETTINGS = {
        # Mux bits on left map to array of form [positive input, negative input]
        0b000 => [0, 1],
        0b001 => [0, 3],
        0b010 => [1, 3],
        0b011 => [2, 3],
        0b100 => [0, nil],
        0b101 => [1, nil],
        0b110 => [2, nil],
        0b111 => [3, nil],
      }

      PGA_RANGE = (0..7).to_a
      CONFIG_DEFAULT = [0x05, 0x8B]

      def after_initialize(options={})
        super(options)

        # SPI mode 1 recommended.
        @spi_mode = options[:spi_mode] || 1

        # Mutex and variables for BoardProxy behavior.
        @mutex = Mutex.new
        @active_pin  = nil
        @active_gain = nil

        # Set register bytes to default and write it to device.
        @config_register = CONFIG_DEFAULT.dup
        write(@config_register)

        # Enable BoardProxy callbacks.
        enable_proxy
      end

      def _read(config)
        # Write config register to trigger reading.
        transfer(write: config)
        
        # About 10ms conversion wait for default sample rate.
        sleep 0.010

        # Read the result, triggering callbacks.
        transfer(read: 2)
      end

      # Pack the 2 bytes back into a string, then unpack as big-endian int16.
      def pre_callback_filter(message)
        bytes = message.split(",").map { |b| b.to_i }
        bytes.pack("C*").unpack("s>")[0]
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

      def analog_read(pin, negative_pin=nil, gain=0b010)
        # Wrap in mutex so calls and callbacks are atomic.
        @mutex.synchronize do
          # Set these for callbacks.
          @active_pin  = pin
          @active_gain = gain
          
          # Set MSB of @config_register based on mux settings and gain.
          mux_bits = pins_to_mux_bits(pin, negative_pin)
          raise ArgumentError "wrong gain: #{gain.inspect} given for ADS1118" unless PGA_RANGE.include?(gain)
          @config_register[0] = 0b10000001 | ((mux_bits << 4) | (gain << 1))

          read(@config_register)
        end
      end

      def pins_to_mux_bits(pin, negative_pin)
        # Pin 1 is negative input. Only pin 0 can be read.
        if negative_pin == 1
          unless pin == 0
            raise ArgumentError, "only pin 0 can be read when pin 1 is negative input"
          else
            return 0b000
          end
        end

        # Pin 3 is negative input. Pins 0..2 can be read.
        if negative_pin == 3
          unless [0,1,2].include? pin
            raise ArgumentError, "only pins 0..2 can be read when pin 3 is negative input"
          else
            return 0b001 + pin
          end
        end

        # No negative input. Any pin from 0 to 3 can be read.
        if (0..3).include? pin
          return 0b100 + pin
        else
          raise Argument Error "input pin: #{pin.inspect} given is out of range 0..3"
        end
      end

      def analog_listen(pin, divider=nil)
        raise StandardError, "ADS1118 does not implement #listen. Use #read or #poll instead"
      end

      def stop_listener(pin)
      end
    end
  end
end
