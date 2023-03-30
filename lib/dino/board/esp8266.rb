module Dino
  module Board
    class ESP8266 < Base
      include API::I2C
      include API::Servo
      include API::ShiftIO
      include API::SPI
      include API::Infrared
      include API::OneWire
      include API::Tone
      include API::LEDArray

      DIGITAL_REGEX = /\Ad\d+\z/i
      ANALOG_REGEX  = /\A(a)\d+\z/i
      RAW_REGEX     = /\A\d+\z/i
      GPIO_REGEX    = /\A(gpio)\d+\z/i

      D_PIN_MAP = {
        0  => 16,
        1  => 5,
        2  => 4,
        3  => 0,
        4  => 2,
        5  => 14,
        6  => 12,
        7  => 13,
        8  => 15,
        9  => 3,   # Serial RXD
        10 => 1,   # Serial TXD
      }

      def convert_pin(pin)
        return nil                   if pin == nil
        pin = pin.to_s
        return pin.to_i              if pin.match(RAW_REGEX)
        return gpio_pin_to_i(pin)    if pin.match(GPIO_REGEX)
        return analog_pin_to_i(pin)  if pin.match(ANALOG_REGEX)
        return digital_pin_to_i(pin) if pin.match(DIGITAL_REGEX)
        return "EE"                  if pin == "EE"
        raise ArgumentError, "incorrect pin format: #{pin.inspect}"
      end

      # Only one analog in on the ESP8266, GPIO 17.
      def analog_pin_to_i(pin)
        gpio = pin.gsub(/\Aa/i, '').to_i
        raise ArgumentError, "invalid analog input pin" unless gpio == 0
        17
      end

      def gpio_pin_to_i(pin)
        gpio = pin.gsub(/\Agpio/i, '').to_i
        raise ArgumentError, "invalid GPIO pin" if (gpio < 0 || gpio > 17)
        gpio
      end

      def digital_pin_to_i(pin)
        d_index = pin.gsub(/\Ad/i, '').to_i
        gpio = D_PIN_MAP[d_index]
        raise ArgumentError, "invalid D pin" unless gpio
        gpio
      end
    end
  end
end
