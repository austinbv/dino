module Dino
  module SPI
    class Bus
      include Behaviors::MultiPin
      include Behaviors::BusController
      include Behaviors::Reader

      def transfer(pin, **options)
        board.spi_transfer(pin, **options)
      end

      def listen(pin, **options)
        board.spi_listen(pin, **options)
      end

      def stop(pin)
        board.spi_stop(pin)
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
