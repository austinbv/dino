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

        require_pins(:clock, :input, :output)
      end

      def transfer(select_pin, write: [], read: 0, frequency: nil, mode: 0, bit_order: :msbfirst)
        board.spi_bb_transfer select_pin, clock: pins[:clock], output: pins[:output], input: pins[:input],
                                          write: write, read: read, mode: mode, bit_order: bit_order
      end

      def listen(select_pin, read: 0, frequency: nil, mode: 0, bit_order: :msbfirst)
        board.spi_bb_listen select_pin, clock: pins[:clock], input: pins[:input],
                                        read: read, mode: mode, bit_order: bit_order
      end

      # Uses regular Board#spi_stop since listeners are shared.
      def stop(pin)
        board.spi_stop(pin)
      end

      # Delegate this to board so peripherals can initialize their select pins.
      def set_pin_mode(*args)
        board.set_pin_mode(*args)
      end

      def convert_pin(pin)
        board.convert_pin(pin)
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
