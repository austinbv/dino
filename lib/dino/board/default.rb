module Dino
  module Board
    class Default < Base
      include API::I2C
      include API::Servo
      include API::ShiftIO
      include API::SPI
      include API::Infrared
      include API::OneWire
      include API::Tone

      DIGITAL_REGEX = /\A\d+\z/i
      ANALOG_REGEX = /\A(a)\d+\z/i
      DAC_REGEX = /\A(dac)\d+\z/i

      def convert_pin(pin)
        return nil                  if pin == nil
        pin = pin.to_s
        return pin.to_i             if pin.match(DIGITAL_REGEX)
        return analog_pin_to_i(pin) if pin.match(ANALOG_REGEX) && analog_zero
        return dac_pin_to_i(pin)    if pin.match(DAC_REGEX) && dac_zero
        return "EE"                 if pin == "EE"
        raise ArgumentError, "incorrect pin format: #{pin.inspect}"
      end

      def analog_pin_to_i(pin)
        @analog_zero + pin.gsub(/\Aa/i, '').to_i
      end

      def dac_pin_to_i(pin)
        raise ArgumentError, "board does not specify DAC pins" unless @dac_zero
        @dac_zero + pin.gsub(/\Adac/i, '').to_i
      end
    end
  end
end
