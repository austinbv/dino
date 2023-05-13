module Dino
  module SPI
    class Bus
      include Behaviors::Component
      include Behaviors::BusController
      include Behaviors::Reader

      # Board expects all components to have #pin.
      attr_reader :pin

      # Forward some methods directly to the board.
      extend Forwardable

      # Forward SPI methods with prefixed names.
      def_delegator :board, :spi_transfer,  :transfer
      def_delegator :board, :spi_listen,    :listen
      def_delegator :board, :spi_stop,      :stop

      # Forward pin control methods with same names for board proxying.
      def_delegator :board, :convert_pin
      def_delegator :board, :set_pin_mode

      # Add peripheral to self and the board. It gets callbacks directly from the board.
      def add_component(component)
        pins = components.map { |c| c.pin }
        if pins.include? component.pin
          raise ArgumentError, "duplicate select pin for #{component}"
        end
        components << component
        board.add_component(component)
      end

      # Remove peripheral from self and the board.
      def remove_component(component)
        components.delete(component)
        board.remove_component(component)
      end
    end
  end
end
