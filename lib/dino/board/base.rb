module Dino
  module Board
    class Base
      include Map
      include API::Core
      include API::Pulse
      include API::EEPROM
      include API::I2C
      include API::Servo
      include API::SPI
      include API::SPIBitBang
      include API::Infrared
      include API::OneWire
      include API::Tone
      include API::LEDArray

      attr_reader :board_name, :version, :aux_limit, :eeprom_length
      attr_reader :components
      attr_reader :low, :high, :analog_write_high, :analog_read_high

      def initialize(io, options={})
        # Connect the IO, and get the ACK.
        @io = io
        ack = io.handshake
        @name, @version, @aux_limit, @eeprom_length = ack.split(",")

        # Parse map, version and eeprom_legnth.
        @name          = nil if @name.empty?
        @version       = nil if @version.empty?
        @eeprom_length = @eeprom_length.to_i

        # Leave room for null termination of aux messages.
        @aux_limit = @aux_limit.to_i - 1

        # Load the board map.
        @map = load_map(@name)

        # Allow the IO to call #update on the board when messages received.
        io.add_observer(self)
        
        # Set digital and analog IO levels.
        @low  = 0
        @high = 1
        self.analog_write_resolution = options[:write_bits] || 8
        self.analog_read_resolution = options[:read_bits] || 10

        # Component holder.
        @components = []
      end
      
      def finish_write
        sleep 0.001 while @io.writing?
        write "\n91\n"
        sleep 0.001 while @io.writing?
      end
            
      def analog_write_resolution=(value)
        set_analog_write_resolution(value)
        @write_bits = value
        @analog_write_high = (2 ** @write_bits) - 1
      end
      
      def analog_read_resolution=(value)
        set_analog_read_resolution(value)
        @read_bits = value
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

      #
      # Component generating convenience methods. TODO: add more!
      #
      def eeprom
        @eeprom ||= EEPROM::BuiltIn.new(board: self)
      end

      #
      # Component management stuff.
      #
      def add_component(component)
        @components << component
      end

      def remove_component(component)
        component.stop if component.methods.include? :stop
        @components.delete(component)
      end

      def update(line)
        pin, message = line.split(":", 2)
        pin = pin.to_i unless pin == "EE"
        @components.each do |part|
          part.update(message) if pin == convert_pin(part.pin)
        end
      end
    end
  end
end
