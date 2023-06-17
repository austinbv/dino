module Dino
  module Sensor
    class HTU31D
      include I2C::Peripheral
      include Behaviors::Poller

      # Commands
      RESET           = 0x1E
      RESET_TIME      = 0.015 # Reset time in seconds.
      HEATER_ON       = 0X04
      HEATER_OFF      = 0X02
      READ_T_AND_H    = 0x00 # Returns 6 bytes: [T_MSB, T_LSB, T_CRC, H_MSB, H_LSB, H_CRC]
      READ_H          = 0x10 # Returns 3 bytes: [H_MSB, H_LSB, H_CRC]
      READ_SERIAL     = 0x0A # Returns 6 bytes: [S1, S1_CRC, S2, S2_CRC, S3, S3_CRC]
      READ_DIAGNOSTIC = 0x08 # Returns 1 byte:  [HEATER, T_LOW, T_HIGH, T_RUN, H_LOW, H_HIGH, H_RUN, NVM_ERR]
      #
      # HEATER         : Bit set if heater is turned on.
      # T_LOW / T_HIGH : Bit set if temperature is outside range of -50 to 150 C.
      # H_LOW / H_HIGH : Bit set if humidity is outside range of -10 to 120 % RH.
      # T_RUN / H_RUN  : Bit set if storage register under/overruns, truncated to min or max integer value.
      # NVM_ERR        : Bit set if internal CRC failed.
      #
      START_CONVERSION  = 0x40 # Must be OR'ed with resolution setting bits.

      # User can give resolutions as integer from 0-3, as shown in the datasheet.
      T_RESOLUTIONS = {
        0 => 0x00, # LSBIT = 0.040 C
        1 => 0x02, # LSBIT = 0.025 C
        2 => 0x04, # LSBIT = 0.016 C
        3 => 0x06, # LSBIT = 0.012 C
      }
      H_RESOLUTIONS = {
        0 => 0x00, # LSBIT = 0.020%
        1 => 0x08, # LSBIT = 0.014%
        2 => 0x10, # LSBIT = 0.010%
        3 => 0x18, # LSBIT = 0.007%
      }

      # Leave some margin for error, since this doesn't lock the bus during conversion like the HTU21D.
      CONVERSION_SAFETY_FACTOR = 1.2

      # Conversion times in seconds.
      T_CONVERSION_TIMES = {
        0 => 0.00111 * CONVERSION_SAFETY_FACTOR,
        1 => 0.00214 * CONVERSION_SAFETY_FACTOR,
        2 => 0.00421 * CONVERSION_SAFETY_FACTOR,
        3 => 0.00834 * CONVERSION_SAFETY_FACTOR,
      }
      H_CONVERSION_TIMES = {
        0 => 0.00157 * CONVERSION_SAFETY_FACTOR,
        1 => 0.00306 * CONVERSION_SAFETY_FACTOR,
        2 => 0.00603 * CONVERSION_SAFETY_FACTOR,
        3 => 0.01198 * CONVERSION_SAFETY_FACTOR,
      }

      def before_initialize(options={})
        @i2c_address = 0x40
        super(options)
      end

      def after_initialize(options={})
        super(options)

        # Avoid repeated memory allocation for callback data and state.
        @reading     = { temperature: nil, humidity: nil }
        self.state   = { temperature: nil, humidity: nil }
        @resolutions = { temperature: 0, humidity: 0 }

        reset
      end

      def reset
        i2c_write [RESET]
        sleep RESET_TIME
        @heater_on = false
      end

      def heater_on?
        @heater_on
      end

      def heater_off?
        !@heater_on
      end
      
      def heater_on
        i2c_write [HEATER_ON]
        @heater_on = true
      end

      def heater_off
        i2c_write [HEATER_OFF]
        @heater_on = false
      end
      
      def temperature_resolution
        @resolutions[:temperature]
      end

      def temperature_resolution=(setting)
        raise ArgumentError, "wrong resolution given: #{setting}. Must be in range 0..3" unless (0..3).include?(setting)
        @resolutions[:temperature] = setting
      end
      
      def humidity_resolution
        @resolutions[:humidity]
      end
      
      def humidity_resolution=(setting)
        raise ArgumentError, "wrong resolution given: #{setting}. Must be in range 0..3" unless (0..3).include?(setting)
        @resolutions[:humidity] = setting
      end

      def [](key)
        @state_mutex.synchronize do
          return @state[key]
        end
      end
      
      def _read
        # Calculate total conversion time.
        conversion_time = T_CONVERSION_TIMES[temperature_resolution] +
                          H_CONVERSION_TIMES[humidity_resolution]

        # Build the conversion command from the set resolutions.
        conversion_command = START_CONVERSION | T_RESOLUTIONS[temperature_resolution] | H_RESOLUTIONS[humidity_resolution]

        # Write it and sleep.
        i2c_write [conversion_command]
        sleep conversion_time

        # Write the read command and read back 6 bytes.
        i2c_read(READ_T_AND_H, 6)
      end

      def pre_callback_filter(bytes)
        # Bytes given as: [T_MSB, T_LSB, T_CRC, H_MSB, H_LSB, H_CRC]

        # Temperature
        t_raw = (bytes[0] << 8) | bytes[1]
        if calculate_crc(t_raw) != bytes[2]
          @reading[:temperature] = nil
        else
          @reading[:temperature] = (165 * t_raw.to_f / 65535) - 40
        end

        # Humidity
        h_raw = (bytes[3] << 8) | bytes[4]
        if calculate_crc(h_raw) != bytes[5]
          @reading[:humidity] = nil
        else
          @reading[:humidity] = h_raw.to_f / 655.35
        end

        # Ignore entire reading if either CRC failed.
        return nil unless (@reading[:temperature] && @reading[:humidity])
        @reading
      end
      
      def update_state(reading)
        @state_mutex.synchronize do
          @state[:temperature] = reading[:temperature]
          @state[:humidity]    = reading[:humidity]
        end
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
    end
  end
end
