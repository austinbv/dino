module Smalrubot
  module Components
    class BaseComponent
      attr_reader :board, :pin, :pullup
      alias :pins :pin

      def initialize(options={})
        self.board = options[:board]
        self.pin = options[:pin] || options[:pins]
        self.pullup = options[:pullup]

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

      attr_writer :board, :pin, :pullup
      alias :pins= :pin=

      def digital_write(pin=self.pin, value)
        self.board.digital_write(pin, value)
      end

      def analog_write(pin=self.pin, value)
        self.board.analog_write(pin, value)
      end

      def set_pin_mode(pin=self.pin, mode)
        self.board.set_pin_mode(pin, mode, pullup)
      end
    end
  end
end

