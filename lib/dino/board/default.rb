module Dino
  module Board
    class Default < Base
      include API::Core
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
        pin = pin.to_s
        return pin.to_i             if pin.match(DIGITAL_REGEX)
        return analog_pin_to_i(pin) if pin.match(ANALOG_REGEX)
        return dac_pin_to_i(pin)    if pin.match(DAC_REGEX)
        raise "Incorrect pin format"
      end

      def analog_pin_to_i(pin)
        @analog_zero + pin.gsub(/\Aa/i, '').to_i
      end

      def dac_pin_to_i(pin)
        raise "The board did not specify any DAC pins" unless @dac_zero
        @dac_zero + pin.gsub(/\Adac/i, '').to_i
      end
    end
  end
end
