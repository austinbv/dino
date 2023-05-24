module Dino
  module Sensor
    class BME280
      include I2C::Peripheral
      include Behaviors::Poller
      
      # Reading Mode Settings
      SLEEP_MODE      = 0b00
      ONESHOT_MODE    = 0b01 # 0b10 is also valid. Called "forced mode" in datasheet.
      CONTINUOUS_MODE = 0b11 # Called "normal mode" in datashseet.

      # Standby Times for Normal (Continuous) Mode in milliseconds
      STANDBY_TIMES = {
                        0.5  => 0b000,
                        62.5 => 0b001,
                        125  => 0b010,
                        250  => 0b011,
                        500  => 0b100,
                        1000 => 0b101,
                        10   => 0b110,
                        20   => 0b111,
                      }

      #
      # Oversample Setting Values
      #
      # Note: Each of the 3 sensors has a separate oversample setting, but temperature cannot
      # be skipped, since the other 2 calculations depend on it.
      #
      # General formula:
      #   2 ^ (n-1), where n is the decimal value of the bits, up to 16x max oversampling.
      #
      OVERSAMPLE_FACTORS = {
                              0  =>  0b000, # Sensor skipped. Value will be 0x800000.
                              1  =>  0b001,
                              2  =>  0b010,
                              4  =>  0b011,
                              8  =>  0b100,
                              16 =>  0b101, # 0b110 and 0b111 are also valid for 16x.
                            }
                            
      # IIR Filter Coefficients  
      IIR_COEFFICIENTS = {
                            0  =>  0b000,
                            2  =>  0b001,
                            4  =>  0b010,
                            8  =>  0b011,
                            16 =>  0b100, # 0b101, 0b110 and 0b111 are also valid for 16.
                          }
      
      def before_initialize(options={})
        @i2c_address = 0x76
        super(options)
      end

      def after_initialize(options={})
        super(options)
        get_calibration_data
        
        #
        # Setup defaults for the config registers:
        #   Oneshot reading mode
        #   1x sampling for all sensors
        #   500ms standby time in continuous mode
        #   IIR filter off
        #
        @registers = {
          # Bits 0..1 control operating mode.
          # Bits 2..4 control the pressure oversampling factor
          # Bits 5..7 control the temperature oversampling factor.
          f4: 0b00100110,
        
          # Bits 0..1 should always be 0.
          # Bits 2..4 control the IIR filter coefficient.
          # Bits 5..7 control the standby time when in continuous reading mode.
          f5: 0b10000000,
        }
        # Bits 0..2 control the humidity oversampling factor, on BME280 only.
        # Bits 3+ are unused.
        @registers.merge!(f2: 0b00000001) if humidity_available?
        
        write_settings
      end
      
      #
      # Configuration Methods
      #
      def oneshot_mode
        @registers[:f4] = (@registers[:f4] & 0b11111100) | ONESHOT_MODE
        write_settings
      end
      
      def continuous_mode
        @registers[:f4] = (@registers[:f4] & 0b11111100) | CONTINUOUS_MODE
        write_settings 
      end
      
      def standby_time=(ms)
        raise ArgumentError, "invalid standby time: #{ms}" unless STANDBY_TIMES.keys.include? ms
        
        @registers[:f5] = (@registers[:f5] & 0b00011111) | (STANDBY_TIMES[ms] << 5)
        write_settings
      end
      
      def temperature_samples=(factor)
        raise ArgumentError, "invalid oversampling factor: #{factor}" unless OVERSAMPLE_FACTORS.keys.include? factor
        raise ArgumentError, "temperature must be read. Invalid oversampling factor: #{factor}" if factor == 0
        
        @registers[:f4] = (@registers[:f4] & 0b00011111) | (OVERSAMPLE_FACTORS[factor] << 5)
        write_settings
      end
      
      def pressure_samples=(factor)
        raise ArgumentError, "invalid oversampling factor: #{factor}" unless OVERSAMPLE_FACTORS.keys.include? factor
        
        @registers[:f4] = (@registers[:f4] & 0b11100011) | (OVERSAMPLE_FACTORS[factor] << 2)
        write_settings
      end
      
      def humidity_samples=(factor)
        raise ArgumentError, "invalid oversampling factor: #{factor}" unless OVERSAMPLE_FACTORS.keys.include? factor
        
        @registers[:f2] = (@registers[:f2] & 0b11111000) | OVERSAMPLE_FACTORS[factor]
        write_settings
      end
      
      def iir_coefficient=(coeff)
        raise ArgumentError, "invalid IIR coefficient: #{coeff}" unless IIR_COEFFICIENTS.keys.include? coeff
        
        @registers[:f5] = (@registers[:f5] & 0b11100011) | (IIR_COEFFICIENTS[coeff] << 2)
        write_settings
      end
    
      def write_settings
        # Write humidity setting for BME280 only.
        i2c_write [0xF2, @registers[:f2]] if humidity_available?
        
        # Write temperature and pressure settings.
        i2c_write [0xF5, @registers[:f5], 0xF4, @registers[:f4]]
      end
      
      def config_register_bits
        str = ""
        @registers.each_key do |key|
          str << "0x#{key.upcase}: #{@registers[key].to_s(2).rjust(8, '0')}\n"
        end
        str
      end

      #
      # Override default Callback, Reader and Poller behavior.
      #
      def poll(interval=3, *args, &block)
        # Need to call #read instead of #read to poll.
        poll_using(self.method(:read), interval, *args, &block)
      end
      
      def read(&block)
        # Write register 0xF4 to trigger a oneshot reading and wait, unless continuous mode is enabled.
        unless (@registers[:f4] & 0b00000011 == 0b11)
          i2c_write [0xF4, @registers[:f4]]
          sleep 0.005
        end
        
        # Always read 8 bytes starting at 0xF7, regardless of settings. Keeps data in correct order.
        read_using -> { i2c_read 0xF7, 8 }, &block
      end
      
      def pre_callback_filter(data)
        # Readings are always 8 bytes. Let calibration data pass through unmodified.
        data.length == 8 ? decode(data) : data
      end
      
      def update_state(readings)
        # Prevent calibration data arrays from modifying state.
        self.state = readings if readings.class == Hash
      end
      
      #
      # Decode Data
      #
      def decode(bytes)
        # Always read temperature since t_fine is needed to calibrate other values.
        temperature, t_fine = decode_temperature(bytes)
        results = {temperature: temperature}
      
        # Pressure and humidity are optional. Humidity is not available on the BMP280.
        results[:pressure] = decode_pressure(bytes, t_fine) if reading_pressure?
        results[:humidity] = decode_humidity(bytes, t_fine) if reading_humidity?
          
        results
      end
      
      def decode_temperature(bytes)
        # Reformat raw ADC bytes (20-bits in 24) to a 32-bit integer.
        adc_t = [0, bytes[3], bytes[4], bytes[5]].pack('C*').unpack('L>')[0] >> 4
                  
        # Floating point temperature calculation from datasheet. Result in degrees Celsius.
        var1 = (adc_t /  16384.0 - @calibration[:t1] / 1024.0) * @calibration[:t2]
        var2 = (adc_t / 131072.0 - @calibration[:t1] / 8192.0) ** 2 * @calibration[:t3]
        t_fine = var1 + var2
        temperature = (var1 + var2) / 5120.0
        [temperature, t_fine]
      end
      
      def decode_pressure(bytes, t_fine)
        # Reformat raw ADC bytes (20-bits in 24) to a 32-bit integer.
        adc_p = [0, bytes[0], bytes[1], bytes[2]].pack('C*').unpack('L>')[0] >> 4
        
        # Floating point pressure calculation from datasheet. Result in Pascals.
        var1 = (t_fine / 2.0) - 64000.0
        var2 = var1 * var1 * @calibration[:p6] / 32768.0
        var2 = var2 + var1 * @calibration[:p5] * 2.0
        var2 = (var2 / 4.0) + (@calibration[:p4] * 65536.0)
        var1 = (@calibration[:p3] * var1 * var1 / 524288.0 + @calibration[:p2] * var1) / 524288.0
        var1 = (1.0 + var1 / 32768.0) * @calibration[:p1]
        if var1 == 0
          pressure = nil
        else
          pressure = 1048576.0 - adc_p
          pressure = (pressure - (var2 / 4096.0)) * 6250.0 / var1
          var1 = @calibration[:p9] * pressure * pressure / 2147483648.0
          var2 = pressure * @calibration[:p8] / 32768.0
          pressure = pressure + (var1 + var2 + @calibration[:p7]) / 16.0
        end
        pressure
      end
      
      def decode_humidity(bytes, t_fine)
        # Raw ADC data for humidity is a big-endian unsigned 16-bit integer.
        adc_h = (bytes[6] << 8) | bytes[7]
        
        # Floating point humidity calculation from datasheet. Result in % RH.
        humidity = t_fine - 76800.0
        humidity = (adc_h - (@calibration[:h4] * 64.0 + @calibration[:h5] / 16384.0 * humidity)) *
                    (@calibration[:h2] / 65536.0 * (1.0 + @calibration[:h6] / 67108864.0 * humidity * (1.0 + @calibration[:h3] / 67108864.0 * humidity)))
        humidity = humidity * (1.0 - @calibration[:h1] * humidity / 524288.0)
        humidity = 100.0 if humidity > 100
        humidity = 0.0   if humidity < 0
        humidity
      end

      def reading_pressure?
        # Bits 2..4 of 0xF4 register must not be 0.
        (@registers[:f4] >> 2 & 0b111) != OVERSAMPLE_FACTORS[0]
      end
      
      def reading_humidity?
        return false unless humidity_available?
        # Lowest 3 bits of 0xF2 register must not be 0.
        (@registers[:f2] & 0b111) != OVERSAMPLE_FACTORS[0]
      end
      
      # No humidity on the BMP280.
      def humidity_available?
        !self.class.to_s.match(/bmp/i)
      end
      
      #
      # Calibration
      #
      def get_calibration_data
        # First group of calibration bytes.
        a = read_using -> { i2c_read 0x88, 26 }
        
        @calibration = {
          t1: a[0..1].pack('C*').unpack('S<')[0],
          t2: a[2..3].pack('C*').unpack('s<')[0],
          t3: a[4..5].pack('C*').unpack('s<')[0],

          p1: a[6..7].pack('C*').unpack('S<')[0],
          p2: a[8..9].pack('C*').unpack('s<')[0],
          p3: a[10..11].pack('C*').unpack('s<')[0],
          p4: a[12..13].pack('C*').unpack('s<')[0],
          p5: a[14..15].pack('C*').unpack('s<')[0],
          p6: a[16..17].pack('C*').unpack('s<')[0],
          p7: a[18..19].pack('C*').unpack('s<')[0],
          p8: a[20..21].pack('C*').unpack('s<')[0],
          p9: a[22..23].pack('C*').unpack('s<')[0],
        }
        
        # Second group of calibration bytes, mostly for humidity. Not available on BMP280.
        if humidity_available?
          b = read_using -> { i2c_read 0xE1, 7 }
          @calibration.merge!(
            h1: a[25],
            h2: b[0..1].pack('C*').unpack('s<')[0],
            h3: b[2],
            h4: [(b[3] << 4) | (b[4] & 0b00001111)].pack('S').unpack('s')[0],
            h5: [(b[5] << 4) | (b[4] >> 4)        ].pack('S').unpack('s')[0],
            h6: [b[6]].pack('C').unpack('c')[0]
          )
        end
      end
    end
    
    #
    # BMP280 is mostly compatible with BME280, except for a few changes.
    #
    class BMP280 < BME280
      # Last 2 standby times are different for the BMP280 vs BME280.
      STANDBY_TIMES = {
                        0.5  => 0b000,
                        62.5 => 0b001,
                        125  => 0b010,
                        250  => 0b011,
                        500  => 0b100,
                        1000 => 0b101,
                        2000 => 0b110,
                        4000 => 0b111,
                      }
                      
      def standby_time=(ms)
        raise ArgumentError, "invalid standby time: #{ms}" unless STANDBY_TIMES.keys.include? ms

        @registers[:f5] = (@registers[:f5] & 0b00011111) | (STANDBY_TIMES[ms] << 5)
        write_settings
      end
    end
  end
end
