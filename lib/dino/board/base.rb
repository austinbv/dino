module Dino
  module Board
    class Base
      attr_reader :high, :low, :analog_high, :components, :analog_zero, :dac_zero

      def initialize(io, options={})
        @io, @components = io, []

        ack = io.handshake.split(",").map { |num| num.to_i }
        @aux_limit, @analog_zero, @dac_zero = ack

        io.add_observer(self)
        self.analog_resolution = options[:bits] || 8
      end

      def analog_resolution=(value)
        @bits = value || 8
        write Dino::Message.encode(command: 96, value: @bits)
        @low  = 0
        @high = 1
        @analog_high = (2 ** @bits) - 1
      end

      # Aux limits differ per board depending on RAM, 39 is the safe minimum.
      def aux_limit
        @aux_limit ||= 39
      end

      def write(msg)
        @io.write(msg)
      end

      def update(pin, msg)
        @components.each do |part|
          part.update(msg) if pin.to_i == part.pin
        end
      end

      def add_component(component)
        @components << component
      end

      def remove_component(component)
        stop_listener(component.pin)
        @components.delete(component)
      end
    end
  end
end
