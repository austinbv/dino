module Dino
  module SPI
    class Bus
      include Behaviors::Component
      include Behaviors::BusController
      include Behaviors::Reader

      # Board expects all components to have #pin.
      attr_reader :pin

      def transfer(select_pin, **options)
        board.spi_transfer(select_pin, **options)
      end

      def listen(select_pin, **options)
        board.spi_listen(select_pin, **options)
      end

      def stop(select_pin)
        board.spi_stop(select_pin)
      end

      # Delegate necessary methods for chip enable and callbacks directly to the board.
      def set_pin_mode(*args)
        board.set_pin_mode(*args)
      end

      def add_component(component)
        board.add_component(component)
      end

      def remove_component(component)
        board.remove_component(component)
      end
    end
  end
end
