module Dino
  module Components
    class BaseComponent
      attr_reader :pin, :board
      alias :pins :pin

      def initialize(options={})
        self.pin = options[:pin] || options[:pins]
        self.board = options[:board]

        raise 'board and pin or pins are required for a component' if self.board.nil? || self.pin.nil?
      end

      protected

      attr_writer :pin, :board
      alias :pins= :pin=

      def digital_write(value, pin = self.pin)
        self.board.digital_write(pin, value)
      end

      def analog_write(value, pin = self.pin)
        self.board.analog_write(pin, value)
      end

      def set_pin_mode(value, pin = self.pin)
        self.board.digital_write(pin, value)
      end
    end
  end
end

