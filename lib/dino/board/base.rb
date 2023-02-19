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
      
      def finish_write
        sleep 0.001 while @io.writing?
        write "\n91\n"
        sleep 0.001 while @io.writing?
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
      
      def eeprom
        @eeprom ||= Components::Basic::BoardEEPROM.new(board: self)
      end

      def write(msg)
        @io.write(msg)
      end

      def update(line)
        update_component(line)
      end

      def update_component(line)
        pin, message = line.split(":", 2)
        pin = pin.to_i unless pin == "EE"
        @components.each do |part|
          part.update(message) if pin == convert_pin(part.pin)
        end
      end

      def add_component(component)
        @components << component
      end

      def remove_component(component)
        component.stop if component.methods.include? :stop
        @components.delete(component)
      end
    end
  end
end
