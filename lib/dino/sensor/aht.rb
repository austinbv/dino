module Dino
  module Sensor
    class AHT10
      include I2C::Peripheral
      include Behaviors::Poller

      # Commands
      INIT_AND_CALIBRATE   = [0xE1, 0x08, 0x00] 
      READ_STATUS_REGISTER = [0x71]
      START_MEASUREMENT    = [0xAC, 0x33, 0x00]
      SOFT_RESET           = [0xBA]

      # Delay Times (in seconds)
      POWER_ON_DELAY = 0.100
      COMMAND_DELAY  = 0.010
      MEASURE_DELAY  = 0.080
      RESET_DELAY    = 0.020

      # CRC Constants
      CRC_INITIAL_VALUE = 0xFF
      CRC_POLYNOMIAL    = 0x31
      MSBIT_MASK        = 0x80

      # Status Register Masks
      CALIBRATED        = 0x08
      BUSY              = 0x80

      # Number of bytes in each reading.
      DATA_LENGTH       = 6

      def before_initialize(options={})
        @i2c_address = 0x38
        super(options)
      end

      def after_initialize(options={})
        super(options)

        # Avoid repeated memory allocation for callback data and state.
        @reading         = { temperature: nil, humidity: nil }
        self.state       = { temperature: nil, humidity: nil }
        @status_register = 0x00

        sleep(self.class::POWER_ON_DELAY)
        reset
        calibrate
      end

      def reset
        i2c_write(SOFT_RESET)
        sleep(RESET_DELAY)
      end

      def calibrated?
        # Should always be true, since INIT_AND_CALIBRATE always sets the calibration bit.
        @status_register & CALIBRATED
      end

      def busy?
        # Should always be false once correct wait times are used.
        @status_register & BUSY
      end

      def calibrate
        i2c_write(self.class::INIT_AND_CALIBRATE)
        sleep(COMMAND_DELAY)
        read_status_register
      end

      def read_status_register
        read_using -> { i2c_read(READ_STATUS_REGISTER, 1) }
        sleep(COMMAND_DELAY)
      end

      def _read
        i2c_write(START_MEASUREMENT)
        sleep(MEASURE_DELAY)
        i2c_read(nil, self.class::DATA_LENGTH)
      end

      def pre_callback_filter(bytes)
        # Handle reading status byte only.
        if bytes.length == 1
          @status_register = bytes[0]
          return nil
        end

        # Normal readings are 6 bytes given as:
        #   [STATUS, H19-H12, H11-H4, H3-H0+T19-T16, T15-T8, T7-T0]
        @status_register = bytes[0]

        # Humidity uses the upper 4 bits of the shared byte as its lowest 4 bits.
        h_raw = ((bytes[1] << 16) | (bytes[2] << 8) | (bytes[3])) >> 4
        @reading[:humidity] = (h_raw.to_f / 2**20) * 100

        # Temperature uses the lower 4 bits of the shared byte as its highest 4 bits.
        t_raw = ((bytes[3] & 0x0F) << 16) | (bytes[4] << 8) | bytes[5]
        @reading[:temperature] = (t_raw.to_f / 2**20) * 200 - 50

        @reading
      end

      def update_state(reading)
        @state_mutex.synchronize do
          @state[:temperature] = reading[:temperature]
          @state[:humidity]    = reading[:humidity]
        end
      end
    end
  end
end

module Dino
  module Sensor
    class AHT20 < AHT10
      include I2C::Peripheral
      include Behaviors::Poller
      #
      # Changed constants compared to AHT10. Always access with self.class::CONSTANT_NAME
      # in shared methods coming from the superclass.
      #
      INIT_AND_CALIBRATE = [0xBE, 0x08, 0x00] 
      POWER_ON_DELAY     = 0.100
      DATA_LENGTH        = 7

      # CRC Constants (unique to AHT20)
      CRC_INITIAL_VALUE = 0xFF
      CRC_POLYNOMIAL    = 0x31
      MSBIT_MASK        = 0x80

      def pre_callback_filter(bytes)
        # Handle reading status byte only.
        return super(bytes) if bytes.length == 1

        # Normal readings are 7 bytes given as:
        #   [STATUS, H19-H12, H11-H4, H3-H0+T19-T16, T15-T8, T7-T0, CRC]
        #
        # Ignore everything if CRC fails.
        return nil if calculate_crc(bytes) != bytes.last

        # Same calculation as AHT10 once CRC passes.
        super(bytes)
      end

      def calculate_crc(bytes)
        crc = CRC_INITIAL_VALUE

        # Ignore last byte. That's the CRC value to compare with.
        bytes.take(bytes.length - 1).each do |byte|
          crc = crc ^ byte
          8.times do
            if (crc & MSBIT_MASK) > 0
              crc = (crc << 1) ^ CRC_POLYNOMIAL
            else
              crc = crc << 1
            end
          end
        end
        
        # Limit CRC size to 8 bits.
        crc = crc & 0xFF
      end
    end
  end
end
