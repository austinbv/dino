module Dino
  module Sensor
    class HTU21D
      include I2C::Peripheral
      include Behaviors::Reader

      # Commands
      SOFT_RESET                = 0xFE
      WRITE_CONFIG              = 0xE6
      READ_TEMPERATURE_BLOCKING = 0xE3
      READ_HUMIDITY_BLOCKING    = 0xE5

      # Config values
      CONFIG_DEFAULT            = 0b00000011
      HEATER_MASK               = 0b00000100
      RESOLUTION_MASK           = 0b10000001

      RESOLUTION_SETTINGS       = [0x00, 0x01, 0x80, 0x81]

      def before_initialize(options={})
        @i2c_address = 0x40
        super(options)
      end

      def after_initialize(options={})
        super(options)

        # Avoid repeated memory allocation for callback data and state.
        @reading   = [:temperatue, 0.0]
        self.state = { temperature: nil, humidity: nil }

        # Temperature and humidity objects, to treat this like 2 sensors.
        @temperature = Temperature.new(self)
        @humidity    = Humidity.new(self)

        @config = CONFIG_DEFAULT
        reset
        heater_off
      end

      attr_reader :temperature, :humidity

      def reset
        i2c_write [SOFT_RESET]
        sleep 0.015
      end

      def write_config
        i2c_write [WRITE_CONFIG, @config]
      end

      def heater_on?
        (@config & HEATER_MASK) > 0
      end

      def heater_off?
        !heater_on?
      end

      def heater_on
        @config |= HEATER_MASK
        write_config
      end

      def heater_off
        @config &= ~HEATER_MASK
        write_config
      end

      #
      # Only 4 resolution combinations are available, and need to be
      # set by giving a bitmask from the datasheet:
      #   0x00 = 14-bit temperature, 12-bit humidity
      #   0x01 = 12-bit temperature,  8-bit humidity (default)
      #   0x80 = 13-bit temperature, 10-bit humidity
      #   0x81 = 11-bit temperature, 11-bit humidity
      #
      def resolution=(mask)
        raise ArgumentError, "wrong resolution bitmask given: #{mask}" unless RESOLUTION_SETTINGS.include? mask
        @config &= ~RESOLUTION_MASK
        @config |= mask
        write_config
      end

      def resolution
        resolution_mask = @config & RESOLUTION_MASK
        case resolution_mask
        when 0x00
          {temperature: 14, humidity: 12}
        when 0x01
          {temperature: 12, humidity: 8}
        when 0x80
          {temperature: 13, humidity: 10}
        when 0x81
          {temperature: 11, humidity: 11}
        else
          raise StandardError, "cannot get resolution from config register: #{@config}"
        end
      end

      def [](key)
        @state[key]
      end
      
      def read_temperature
        result = read_using -> { i2c_read(READ_TEMPERATURE_BLOCKING, 3)}
        (result[0] == :temperature) ? result[1] : nil
      end

      def read_humidity
        result = read_using -> { i2c_read(READ_HUMIDITY_BLOCKING, 3)}
        (result[0] == :humidity) ? result[1] : nil
      end

      def pre_callback_filter(bytes)
        # Raw value is first 2 bytes big-endian.
        raw_value = (bytes[0] << 8) | bytes[1]

        # Quietly ignore readings with bad CRC.
        unless calculate_crc(raw_value) == bytes[2]
          @humidity.update(nil)
          @temperature.update(nil)
          return nil
        end

        # Lowest 2 bits must be zeroed before conversion.
        raw_value = raw_value & 0xFFFC

        # Bit 1 of LSB determines type of reading; 0 for temperature, 1 for humidity.
        if (bytes[1] & 0b00000010) > 0
          @reading[0] = :humidity
          @reading[1] = (raw_value.to_f / 524.288) - 6
          @humidity.update(@reading[1])
        else
          @reading[0] = :temperature
          @reading[1] = (175.72 * raw_value.to_f / 65536) - 46.8
          @temperature.update(@reading[1])
        end
        @reading
      end

      #
      # CRC calculation adapted from offical driver, found here:
      # https://github.com/TEConnectivity/HTU21D_Generic_C_Driver/blob/master/htu21d.c#L275
      #
      def calculate_crc(value)
        polynomial = 0x988000   # x^8 + x^5 + x^4 + 1
        msb        = 0x800000
        mask       = 0xFF8000
        result     = value << 8 # Pad right with length of output CRC

        while msb != 0x80
          result = ((result ^ polynomial) & mask) | (result & ~mask) if (result & msb !=0)
          msb        >>= 1
          mask       >>= 1
          polynomial >>= 1
        end
        result
      end

      def update_state(reading)
        @state_mutex.synchronize do
          @state[reading[0]] = reading[1]
        end
      end
    end
  end
end
