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

      # Delegate this to board so peripherals can initialize their select pins.
      def set_pin_mode(*args)
        board.set_pin_mode(*args)
      end

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
