module Dino
  module SPI
    class BitBang
      include Behaviors::MultiPin
      include Behaviors::BusController
      include Behaviors::Reader

      def initialize_pins(options={})
        # Allow pin aliases.
        pins[:input]  = pins[:input]  || pins[:poci] || pins[:miso]
        pins[:output] = pins[:output] || pins[:pico] || pins[:mosi]
        pins[:clock]  = pins[:clock]  || pins[:sck]  || pins[:clk]

        # Clean up the pins hash.
        [:poci, :miso, :pico, :mosi, :sck, :clk].each { |key| pins.delete(key) }

        # Validate input or output pin.
        unless pins[:input] || pins[:output]
          raise ArgumentError, "no input or output pin given. Require either or both"
        end

        # If only output or input, set the other 255 for a one-directional bus.
        pins[:input]  = 255 if pins[:output] && !pins[:input]
        pins[:output] = 255 if pins[:input]  && !pins[:output]

        # Ensure clock pin is given.
        require_pin(:clock)

        # Ensure pins are unique and convert them to integer.
        super(options)
      end

      def transfer(select_pin, **options)
        options.merge!(pin_hash)
        board.spi_bb_transfer(select_pin, **options)
      end

      def listen(select_pin, **options)
        options.merge!(pin_hash)
        board.spi_bb_listen(select_pin, **options)
      end

      def pin_hash
        { input: pins[:input], output: pins[:output], clock: pins[:clock] }
      end

      # Uses regular Board#spi_stop since listeners are shared.
      def stop(pin)
        board.spi_stop(pin)
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
