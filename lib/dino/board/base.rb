module Dino
  module Board
    class Base
      include API::Core
      include API::EEPROM

      attr_reader :components, :high, :low, :analog_write_high, :analog_read_high
      attr_reader :analog_zero, :dac_zero, :eeprom_length

      def initialize(io, options={})
        @io, @components = io, []

        ack = io.handshake.split(",").map(&:to_i)
        @aux_limit, @eeprom_length, @analog_zero, @dac_zero = ack

        # Leave room for null termination of aux messages.
        @aux_limit = @aux_limit - 1

        io.add_observer(self)
        
        @low  = 0
        @high = 1
        self.analog_write_resolution = options[:write_bits] || 8
        self.analog_read_resolution = options[:read_bits] || 10
      end
      
      def finish_write
        sleep 0.001 while @io.writing?
        write "\n91\n"
        sleep 0.001 while @io.writing?
      end
            
      def analog_write_resolution=(value)
        write Dino::Message.encode(command: 96, value: @write_bits = value)
        @analog_write_high = (2 ** @write_bits) - 1
      end
      
      def analog_read_resolution=(value)
        write Dino::Message.encode(command: 97, value: @read_bits = value)
        @analog_read_high = (2 ** @read_bits) - 1
      end
      
      def analog_write_resolution
        @write_bits
      end

      def analog_read_resolution
        @read_bits
      end
      
      alias :pwm_high :analog_write_high
      alias :dac_high :analog_write_high
      alias :adc_high :analog_read_high
      
      # Aux limits differ per board depending on RAM, 39 is the safe minimum.
      def aux_limit
        @aux_limit ||= 48
      end
      
      def eeprom
        @eeprom ||= Components::Basic::BoardEEPROM.new(board: self)
      end

      def write(msg)
        @io.write(msg)
      end

      #
      # Use Board#write_and_halt to call C++ board functions that disable interrupts
      # for a long time. "Long" being more than 1 serial character (~85us for 115200 baud).
      #
      # The "halt" part tells the TxRx to halt transmission to the board after this message.
      # Since it expects interrupts to be disabled, any data sent could be lost.
      #  
      # When the board function has re-enabled interrupts, it should call sendReady(). That
      # signal is read by the TxRx, telling it to resume transmisison.
      #
      def write_and_halt(msg)
        @io.write(msg, true)
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
