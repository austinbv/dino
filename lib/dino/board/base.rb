module Dino
  module Board
    class Base
      include API::Core
      include API::EEPROM

      attr_reader :high, :low, :analog_high, :components
      attr_reader :analog_zero, :dac_zero, :eeprom_length

      def initialize(io, options={})
        @io, @components = io, []

        ack = io.handshake.split(",").map(&:to_i)
        @aux_limit, @eeprom_length, @analog_zero, @dac_zero = ack

        # Leave room for null termination of aux messages.
        @aux_limit = @aux_limit - 1

        io.add_observer(self)
        self.analog_resolution = options[:bits] || 8
      end

      def analog_resolution
        @bits ||= 8
      end

      def analog_resolution=(value)
        @bits = value
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

      def update(line)
        case line
        when /\AEE:/
          update_eeprom(line)
        else
          update_component(line)
        end
      end

      def update_eeprom(line)
        message = line.split(":", 2)[1]
        @components.each do |part|
          part.update(message) if part.pin == "EE"
        end
      end

      def update_component(line)
        pin, message = line.split(":", 2)
        @components.each do |part|
          part.update(message) if pin.to_i == convert_pin(part.pin)
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
