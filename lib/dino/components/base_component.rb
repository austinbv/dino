module Dino
  module Components
    class BaseComponent
      attr_reader :pin, :board
      alias :pins :pin

      def initialize(options={})
        self.pin = options[:pin] || options[:pins]
        self.board = options[:board]

        raise 'board and pin or pins are required for a component' if self.board.nil? || self.pin.nil?
        after_initialize(options)
      end

      #
      # As BaseComponent does a lot of work for you with regarding to setting up, it is
      # best not to override #initialize and instead define an #after_initialize method
      # within your subclass.
      #
      # @note This method should be implemented in the BaseComponent subclass.
      #
      def after_initialize(options={}) ; end

      protected

      attr_writer :pin, :board
      alias :pins= :pin=

      def digital_write(value, pin = self.pin)
        self.board.digital_write(pin, value)
      end

      def analog_write(value, pin = self.pin)
        self.board.analog_write(pin, value)
      end

      def set_pin_mode(mode, pin = self.pin)
        self.board.set_pin_mode(pin, mode)
      end
    end
  end
end

