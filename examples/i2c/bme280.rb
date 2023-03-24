#
# Example using a BME280 sensor over I2C, for temperature, pressure and humidity.
#
require 'bundler/setup'
require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)

# Only pass the SDA pin of the I2C bus. SCL (clock) pin must be 
# connected for it to work, but we don't need to control it.
#
# Arduino Uno:        SDA = 'A4'   SCL = 'A5'
# Leonardo:           SDA =   2    SCL =   3
# Due / Mega / Zero:  SDA =  20    SCL =  21
# ESP8266 :           SDA =   4    SCL =   5
# ESP32:              SDA =  21    SCL =  22
#
# On the ESP8266, 'D2' and 'D1' also map to SDA and SCL respectively.
# This is for convenience when working with common development boards.
#
bus = Dino::Components::I2C::Bus.new(board: board, pin: 20)

sensor = Dino::Components::I2C::BME280.new(bus: bus, address: 0x76)

# Use A BMP280 with no humidity instead.
# sensor = Dino::Components::I2C::BMP280.new(bus: bus, address: 0x76)

# Default reading mode is oneshot (forced).
# sensor.oneshot_mode

# Enable oversampling independently on each sensor.
# sensor.temperature_samples = 8
# sensor.pressure_samples = 2
# sensor.humidity_samples = 4

# Enable continuous reading mode (normal), with standby time and IIR filter.
# sensor.continuous_mode
# sensor.standby_time = 62.5
# sensor.iir_coefficient = 4

# Print raw config register bits.
# print sensor.config_register_bits

def display_reading(reading)
  # Time
  print "#{Time.now.strftime '%Y-%m-%d %H:%M:%S'} - "
  
  # Temperature
  formatted_temp = reading[:temperature].round(2).to_s.ljust(5, '0')
  print "Temperature: #{formatted_temp} \xC2\xB0C"
  
  # Pressure
  if reading[:pressure]
    formatted_pressure = (reading[:pressure] / 101325).round(5).to_s.ljust(7, '0')
    print " | Pressure #{formatted_pressure} atm"
  end
  
  # Humidity  
  if reading[:humidity]
    formatted_humidity = reading[:humidity].round(2).to_s.ljust(5, '0')
    print " | Humidity #{formatted_humidity} %"
  end
  
  puts
end

# Poll the sensor and print readings.
sensor.poll(5) do |reading|
  display_reading(reading)
end

sleep